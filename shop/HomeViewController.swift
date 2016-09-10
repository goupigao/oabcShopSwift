//
//  HomeViewController.swift
//  shop
//
//  Created by goupigao on 16/8/30.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit
import Alamofire
import DropdownMenu

class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    //MARK: 属性
    @IBOutlet weak var changeCityButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var typeArray:[Type] = Array()
    
    //MARK: 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.tintColor = MyColor.green

        setView()
        initCity()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if typeArray.count == 0 {
            loadTypes()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //解决UITableView的分割线不能全屏，靠左的问题
        //设置separatorInset(iOS7之后)
        if self.tableView.respondsToSelector(Selector("setSeparatorInset:")) {
            self.tableView.separatorInset = UIEdgeInsetsZero
        }
        //设置layoutMargins(iOS8之后)
        if self.tableView.respondsToSelector(Selector("setLayoutMargins:")) {
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: tableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("homeTypeCell", forIndexPath: indexPath)  as! HomeTypeCell
        cell.typeImage.image = UIImage(named: "type\(typeArray[indexPath.row].id!)") ?? UIImage(named: "typeNoPic")
        cell.typeImage.contentMode = UIViewContentMode.ScaleAspectFit
        cell.typeImage.layer.borderWidth = 1
        cell.typeImage.layer.borderColor = MyColor.grey.CGColor
        cell.title.text = typeArray[indexPath.row].name
        cell.index = indexPath.row
        cell.selectionStyle = .None
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //print(scrollView.contentOffset.y)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //解决UITableView的分割线不能全屏，靠左的问题
        //设置separatorInset(iOS7之后)
        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
            cell.separatorInset = UIEdgeInsetsZero
        }
        //设置layoutMargins(iOS8之后)
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("Goods") as! GoodsViewController
        viewController.typeId = typeArray[indexPath.row].id!
        viewController.typeName = typeArray[indexPath.row].name
        self.navigationController?.showViewController(viewController, sender: nil)
    }
    
    //MARK: 初始化视图
    func setView() {
        self.title = "首页"
        self.navigationController?.navigationBar.tintColor = MyColor.green
        changeCityButton.tintColor = MyColor.green
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 106
        tableView.backgroundColor = UIColor.clearColor()
    }
    
    //MARK: Action & Network
    func initCity() {
        if let city = Cookie.getProvinceName() {
            for i in 0..<AppDelegate.cities.count {
                if city == AppDelegate.cities[i] {
                    AppDelegate.cityIndex = i
                    break
                }
            }
        }else{
            AppDelegate.cityIndex = 0
            Cookie.setProvinceName(AppDelegate.cities[0])
        }
        changeCityButton.title = "\(AppDelegate.cities[AppDelegate.cityIndex])▼"
    }
    
    @IBAction func changeCity(sender: AnyObject) {
        var items:[DropdownItem] = Array()
        for city in AppDelegate.cities {
            items.append(DropdownItem(title: city))
        }
        let menuView = DropdownMenu(navigationController: navigationController!, items: items, selectedRow: AppDelegate.cityIndex)
        menuView.delegate = self
        menuView.showMenu(onNavigaitionView: false)
    }
    
    func loadTypes() {
        Alamofire.request(.GET, "http://shop.oabc.cc:88/zgMBFrontShopV2/").responseString { (response) in
            guard let html = response.result.value else { return }
            if response.result.error != nil { return }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                let nsHtml = html as NSString
                let regular = try! NSRegularExpression(pattern: "<div class=\"left_menu_sub_a\".*?typeId=(\\d*?)&.*?>(.*?)</a>.*?</div>", options:.DotMatchesLineSeparators)
                let results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(0, html.characters.count))
                for result in results {
                    let type = Type()
                    type.id = (nsHtml.substringWithRange(result.rangeAtIndex(1)) as NSString).integerValue
                    type.name = nsHtml.substringWithRange(result.rangeAtIndex(2)).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    self.typeArray.append(type)
                }
                dispatch_async(dispatch_get_main_queue(), {
                    if results.count>0 {
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
}

extension HomeViewController: DropdownMenuDelegate {
    func dropdownMenu(dropdownMenu: DropdownMenu, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alert = UIAlertController(title: "警告", message: "切换城市将会清空您的购物车，是否继续？", preferredStyle: .Alert)
        let cancelAlertAction:UIAlertAction = UIAlertAction(title: "取消", style: .Cancel) { (cancelButton) -> Void in
        }
        let sureAlertAction:UIAlertAction = UIAlertAction(title: "切换", style: .Default) { (sureButton) -> Void in
            AppDelegate.cityIndex = indexPath.row
            Cart.clearArchive()
            self.changeCityButton.title = "\(AppDelegate.cities[AppDelegate.cityIndex])▼"
            Cookie.setProvinceName(AppDelegate.cities[AppDelegate.cityIndex])
        }
        alert.addAction(cancelAlertAction)
        alert.addAction(sureAlertAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
