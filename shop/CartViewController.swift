//
//  CartViewController.swift
//  shop
//
//  Created by goupigao on 16/8/30.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit
import Alamofire

class CartViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    //MARK: 属性
    @IBOutlet weak var tableView: UITableView!
    var footView:CartFootView?
    var rightButton:UIBarButtonItem?
    
    var cartArray = Array<Cart>()
    var purchaseForm = PurchaseForm()

    //MARK: 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        setView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cartArray = loadCartArray()
        tableView.reloadData()
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
        return cartArray.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cartCartCell", forIndexPath: indexPath)  as! CartCartCell
        if cell.index == -1 {
            cell.stepper.addTarget(self, action: #selector(modifyCart(_:)), forControlEvents: .ValueChanged)
        }
        let index = cartArray.count-1-indexPath.row
        cell.index = index
        cell.name.text = cartArray[index].name
        cell.couponPrice.text = "￥\(cartArray[index].couponPrice)"
        cell.count.text = "\(cartArray[index].count)"
        cell.stepper.value = (Double)(cartArray[index].count)
        cell.selectionStyle = .None
        return cell
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
        return 80
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        footView!.empty.frame = CGRectMake(0,0,tableView.frame.width,80)
        footView!.totalPrice.frame = CGRectMake(0,13,tableView.frame.width-8,21)
        footView!.purchase.frame = CGRectMake(tableView.frame.width-88,37,80,30)
        updateFootView()
        return footView!
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "删除"
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            deleteFromCart(cartArray.count-1-indexPath.row)
        }
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    //MARK: 初始化视图
    func setView() {
        self.title = "购物车"
        self.navigationController?.navigationBar.tintColor = MyColor.green
        rightButton = UIBarButtonItem(title: "编辑", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(editTableView))
        rightButton?.tintColor = MyColor.green
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 74
        tableView.rowHeight = UITableViewAutomaticDimension//实现Self-sizing Cells，但这个方法对没有压缩阻力的view不起作用
        footView = CartFootView(reuseIdentifier: "footView")
        footView!.purchase.addTarget(self, action: #selector(purchase), forControlEvents: .TouchUpInside)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
    }
    
    //MARK: Action & Network
    func getTotalPrice() -> Double {
        var totalPrice = 0.0
        for cart in cartArray {
            totalPrice += (Double)(cart.count) * cart.couponPrice
        }
        return totalPrice
    }
    
    func modifyCart(stepper: UIStepper) {
        var uiview = stepper as UIView
        while (!uiview.isKindOfClass(CartCartCell)) {
            uiview = uiview.superview!
        }
        let cell = uiview as! CartCartCell
        if stepper.value > 0 {
            cartArray[cell.index].count = (Int)(stepper.value)
            cell.count.text = "\((Int)(stepper.value))"
            updateFootView()
            saveCartArray()
        }else{
            deleteFromCart(cell.index)
        }
    }
    
    func deleteFromCart(index:Int){
        cartArray.removeAtIndex(index)
        if cartArray.count == 0 {
            tableView.setEditing(false, animated: true)
            rightButton!.title = "编辑"
        }
        tableView.reloadData()
        //updateFootView()
        saveCartArray()
    }
    
    func saveCartArray() {
        NSKeyedArchiver.archiveRootObject(cartArray, toFile: Cart.ArchiveURL.path!)
    }
    
    func loadCartArray() -> [Cart] {
        if let cartArray = NSKeyedUnarchiver.unarchiveObjectWithFile(Cart.ArchiveURL.path!) as? [Cart] {
            return cartArray
        }else{
            return Array<Cart>()
        }
    }
    
    func updateFootView() {
        if cartArray.count == 0 {
            footView!.empty.hidden = false
            footView!.totalPrice.hidden = true
            footView!.purchase.hidden = true
            navigationItem.rightBarButtonItem = nil
        }else{
            footView!.empty.hidden = true
            footView!.totalPrice.text = "总价：￥\(getTotalPrice())"
            footView!.totalPrice.hidden = false
            footView!.purchase.hidden = false
            navigationItem.rightBarButtonItem = rightButton!
        }
    }
    
    func editTableView(){
        tableView.setEditing(!tableView.editing, animated: true)
        rightButton!.title = tableView.editing ? "完成" : "编辑"
    }
    
    func purchase() {
        if !(AppDelegate.logged ?? false) {
            let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("Login") as! LoginViewController
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.showViewController(viewController, sender: nil)
        }else{
            let alert = UIAlertController(title: "正在提交到云端", message: nil, preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            let city = Cookie.getProvinceName()!
            var tempCity = AppDelegate.cities[0]
            for i in 0..<AppDelegate.cities.count {
                if city == AppDelegate.cities[i] {
                    tempCity = AppDelegate.cities[i==0 ? 1 :0]
                    break
                }
            }
            Cookie.setProvinceName(tempCity)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                var response = Alamofire.request(.GET, "http://shop.oabc.cc:88/zgMBFrontShopV2/ShoppingCart.aspx").responseStringSync()
                let html = (response.result.value)!
                let nsHtml = html as NSString
                let regular = try! NSRegularExpression(pattern: "__VIEWSTATE\" value=\"(.*?)\".*?__EVENTVALIDATION\" value=\"(.*?)\"", options:.DotMatchesLineSeparators)
                let results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(0, html.characters.count))
                Alamofire.request(.POST, "http://shop.oabc.cc:88/zgMBFrontShopV2/ShoppingCart.aspx",parameters: [
                    "__EVENTTARGET":"ctl00$UcHeader1$ucHeaderNavigator_Member1$DDL_DeliverCity",
                    "__VIEWSTATE":nsHtml.substringWithRange(results[0].rangeAtIndex(1)),
                    "__EVENTVALIDATION":nsHtml.substringWithRange(results[0].rangeAtIndex(2)),
                    "ctl00$UcHeader1$ucHeaderNavigator_Member1$DDL_DeliverCity":city
                    ]).responseStringSync()
                for cart in self.cartArray {
                    Alamofire.request(.GET, "http://shop.oabc.cc:88/zgMBFrontShopV2/Purchase.aspx?call=myajax&type=single&supplyId=\(cart.goodId!)&itemCount=\(cart.count)").responseStringSync()
                }
                response = Alamofire.request(.GET, "http://shop.oabc.cc:88/zgMBFrontShopV2/ShoppingConfirm.aspx").responseStringSync()
                let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("Purchase") as! PurchaseViewController
                viewController.hidesBottomBarWhenPushed = true
                viewController.purchaseForm = OabcApi.parsePurchaseForm(response.result.value!)
                dispatch_async(dispatch_get_main_queue(), {
                    alert.dismissViewControllerAnimated(false, completion: {
                        self.navigationController?.showViewController(viewController, sender: nil)
                    })
                })
            })
        }
    }
}

//MARK:tableView
class CartFootView:UITableViewHeaderFooterView {
    let empty = UILabel()
    let totalPrice = UILabel()
    let purchase = UIButton()
    
    override init(reuseIdentifier: String?){
        super.init(reuseIdentifier: reuseIdentifier)
        empty.textAlignment = .Center
        empty.text = "购物车是空的"
        addSubview(empty)
        totalPrice.textAlignment = .Right
        addSubview(totalPrice)
        purchase.setTitle("去结算", forState: .Normal)
        purchase.backgroundColor = MyColor.buttonBg
        addSubview(purchase)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
