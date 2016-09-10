//
//  MineViewController.swift
//  shop
//
//  Created by goupigao on 16/8/30.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit
import Alamofire

class MineViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    //MARK: 属性
    @IBOutlet weak var myInfoView: UIView!
    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var cardNo: UILabel!
    @IBOutlet weak var cardMoney: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var footView:OrdersFootView?
    
    var viewState:String?
    var eventValidation:String?
    var loadingOrders = false
    var hasNextOrdersPage = true
    var pageOfOrders = 0
    var orderArray = Array<Order>()

    //MARK: 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if pageOfOrders==0 {
            loadInfo()
            loadOrders()
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
    
    //MARK:tableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderArray.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("orderCell")
        if cell == nil{
            cell = UITableViewCell(style: .Default, reuseIdentifier: "orderCell")
            cell?.textLabel?.numberOfLines = 0
        }
        cell?.textLabel?.text = "订单号：\(orderArray[indexPath.row].orderNo)\n订单金额：\(orderArray[indexPath.row].orderPrice)\n下单时间：\(orderArray[indexPath.row].createTime)\n配送时间：\(orderArray[indexPath.row].deliveryTime)\n订单状态：\(orderArray[indexPath.row].orderState)"
        cell?.selectionStyle = .None
        return cell!
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
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //var footView:FootView? = tableView.dequeueReusableHeaderFooterViewWithIdentifier("footView") as? FootView
        footView!.label.frame = CGRectMake(0,0,tableView.frame.width,60)
        footView!.indicator.frame = CGRectMake(0,0,tableView.frame.width,60)
        return footView!
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        //footView!.backgroundView?.backgroundColor = UIColor.clearColor()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height * 0.8 {
            loadOrders()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("Order") as! OrderViewController
        viewController.hidesBottomBarWhenPushed = true
        viewController.recId = orderArray[indexPath.row].recId
        self.navigationController?.showViewController(viewController, sender: nil)
    }
    
    //MARK: 初始化视图
    func setView(){
        self.title = "我的"
        self.navigationController?.navigationBar.tintColor = MyColor.green
        myInfoView.layer.borderWidth = 1
        myInfoView.layer.borderColor = MyColor.grey.CGColor
        myInfoView.layer.cornerRadius = 8
        logButton.setTitleColor(MyColor.greenDark, forState: .Normal)
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = MyColor.grey.CGColor
        tableView.layer.cornerRadius = 8
        tableView.estimatedRowHeight = 130
        tableView.backgroundColor = UIColor.clearColor()
        tableView.dataSource = self
        tableView.delegate = self
        footView = OrdersFootView(reuseIdentifier: "footView")
        logButton.addTarget(self, action: #selector(clickLogButton), forControlEvents: .TouchUpInside)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
    }
    
    //MARK: Action & Network
    func clickLogButton(){
        if logButton.currentTitle == "登录" {
            let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("Login") as! LoginViewController
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.showViewController(viewController, sender: nil)
        }else{
            logout()
        }
    }
    
    func loadInfo(){
        Alamofire.request(.GET, "http://shop.oabc.cc:88/zgMBFrontShopV2/myBalance.aspx").responseString { (response) in
            guard let html = response.result.value else { return }
            if response.result.error != nil { return }
            let regular = try! NSRegularExpression(pattern: "ContentPlaceHolder1_UC_Balance1_LBL_CardNumber\">([\\s\\d]*?)</span>.*?ContentPlaceHolder1_UC_Balance1_LBL_Remain1\">([\\s\\d\\.]*?)</span>", options:.DotMatchesLineSeparators)
            let results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(0, html.characters.count))
            dispatch_async(dispatch_get_main_queue(), {
                if results.count > 0 {
                    self.cardNo.text = "卡号：\((html as NSString).substringWithRange(results[0].rangeAtIndex(1)))"
                    self.cardMoney.text = "余额：\((html as NSString).substringWithRange(results[0].rangeAtIndex(2)))"
                    self.logButton.setTitle("注销", forState: .Normal)
                }else{
                    self.removeAll()
                }
            })
        }
    }
    
    func loadOrders(){
        if loadingOrders || !hasNextOrdersPage || !(AppDelegate.logged ?? false) {
            return
        }
        loadingOrders = true
        footView!.indicator.hidden = false
        footView!.indicator.startAnimating()
        footView!.label.hidden = true
        var parameters: [String: AnyObject]? = nil
        if pageOfOrders>0 {
            parameters = ["__VIEWSTATE":viewState!,"__EVENTVALIDATION":eventValidation!,"__EVENTTARGET":"ctl00$ContentPlaceHolder1$UC_Deliver1$myPager$DropDownList_PageIndex","ctl00$ContentPlaceHolder1$UC_Deliver1$myPager$DropDownList_PageIndex":"\(pageOfOrders+1)"]
        }
        Alamofire.request(.GET, "http://shop.oabc.cc:88/zgMBFrontShopV2/MyDeliver.aspx",parameters: parameters).responseString { (response) in
            guard let html = response.result.value else {
                self.loadingOrders = false
                return
            }
            if response.result.error != nil {
                self.loadingOrders = false
                return
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                let nsHtml = html as NSString
                var rangeStart = 0
                var regular = try! NSRegularExpression(pattern: "__VIEWSTATE\" value=\"(.*?)\".*?__EVENTVALIDATION\" value=\"(.*?)\"", options:.DotMatchesLineSeparators)
                var results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(0, html.characters.count))
                rangeStart = results[0].range.location + results[0].range.length
                self.viewState = nsHtml.substringWithRange(results[0].rangeAtIndex(1))
                self.eventValidation = nsHtml.substringWithRange(results[0].rangeAtIndex(2))
                let lastItem = self.orderArray.count
                regular = try! NSRegularExpression(pattern: "<tr>\\s*?<td>([\\s\\d]*?)</td>\\s*?<td>([\\s\\d-]*?)</td>\\s*?<td>([\\s\\d-]*?)</td>.*?￥([\\s\\d\\.]*?)元.*?<td>(.*?)</td>.*?RecID=(\\d+?)&.*?</tr>", options:.DotMatchesLineSeparators)
                results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(rangeStart, html.characters.count-rangeStart))
                if results.count>0 {
                    rangeStart = results[results.count-1].range.location + results[results.count-1].range.length
                }
                for result in results {
                    let order = Order()
                    order.orderNo = nsHtml.substringWithRange(result.rangeAtIndex(1))
                    order.createTime = nsHtml.substringWithRange(result.rangeAtIndex(2))
                    order.deliveryTime = nsHtml.substringWithRange(result.rangeAtIndex(3))
                    order.orderPrice = (nsHtml.substringWithRange(result.rangeAtIndex(4)) as NSString).doubleValue
                    order.orderState = nsHtml.substringWithRange(result.rangeAtIndex(5))
                    order.recId = (nsHtml.substringWithRange(result.rangeAtIndex(6)) as NSString).integerValue
                    self.orderArray.append(order)
                }
                regular = try! NSRegularExpression(pattern: "ContentPlaceHolder1_UC_Deliver1_myPager_Label_Curent.*?selected=\"selected\" value=\"([\\s\\d]*?)\".*?总页数：([\\s\\d]*?)总记录数：", options:.DotMatchesLineSeparators)
                results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(rangeStart, html.characters.count-rangeStart))
                if results.count > 0 {
                    self.pageOfOrders = (nsHtml.substringWithRange(results[0].rangeAtIndex(1)) as NSString).integerValue
                    self.hasNextOrdersPage = (nsHtml.substringWithRange(results[0].rangeAtIndex(2)) as NSString).integerValue>self.pageOfOrders
                }
                dispatch_async(dispatch_get_main_queue(), {
                    if !(AppDelegate.logged ?? false) {
                        self.removeAll()
                        return
                    }
                    if !self.hasNextOrdersPage {
                        self.footView!.indicator.stopAnimating()
                        self.footView!.indicator.hidden = true
                        self.footView!.label.hidden = false
                    }
                    if self.orderArray.count>lastItem {
                        self.tableView.insertRowsAtIndexPaths((lastItem..<self.orderArray.count).map { NSIndexPath(forItem: $0, inSection: 0) }, withRowAnimation: .None)
                    }
                })
                self.loadingOrders = false
            }
        }
    }
    
    func logout(){
        AppDelegate.logged = false
        Alamofire.request(.GET, "http://shop.oabc.cc:88/zgMBFrontShopV2/MyLogout.aspx").responseString { (response) in
            guard let _ = response.result.value else { return }
            if response.result.error != nil { return }
            self.removeAll()
        }
    }
    
    func removeAll(){
        dispatch_async(dispatch_get_main_queue(), {
            self.cardNo.text = "卡号："
            self.cardMoney.text = "余额："
            self.logButton.setTitle("登录", forState: .Normal)
            self.loadingOrders = false
            self.hasNextOrdersPage = true
            self.pageOfOrders = 0
            self.orderArray = Array<Order>()
            self.tableView.reloadData()
            self.footView!.indicator.stopAnimating()
            self.footView!.indicator.hidden = true
            self.footView!.label.hidden = true
        })
    }
}

//MARK:tableView
class OrdersFootView:UITableViewHeaderFooterView {
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    let label = UILabel()
    
    override init(reuseIdentifier: String?){
        super.init(reuseIdentifier: reuseIdentifier)
        indicator.stopAnimating()
        indicator.hidden = true
        indicator.color = MyColor.greenDark
        addSubview(indicator)
        label.numberOfLines = 0
        label.textAlignment = .Center
        label.hidden = true
        label.text = "没有更多订单了"
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
