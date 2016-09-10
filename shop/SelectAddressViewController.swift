//
//  SelectAddressViewController.swift
//  shop
//
//  Created by goupigao on 16/9/5.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit
import Alamofire

class SelectAddressViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    //MARK: 属性
    @IBOutlet weak var tableView: UITableView!
    var footView:SelectAddressFootView?
    
    var purchaseForm = PurchaseForm()

    //MARK: 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        setView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if AppDelegate.purchaseForm != nil {
            purchaseForm = AppDelegate.purchaseForm!
            AppDelegate.purchaseForm = nil
            tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.purchaseForm = purchaseForm
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: tableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchaseForm.addressArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("selectAddressCell", forIndexPath: indexPath)  as! SelectAddressCell
        let address = purchaseForm.addressArray[indexPath.row]
        cell.index = indexPath.row
        cell.radio.image = UIImage(named: address.addressId == AppDelegate.selectAddressId ? "radioSelected" : "radioUnselected")
        cell.address.text =  "\(address.completeAddress)\n\(address.completeContact)"
        cell.edit.addTarget(self, action: #selector(editAddress(_:)), forControlEvents: .TouchUpInside)
        cell.delete.addTarget(self, action: #selector(deleteAddress(_:)), forControlEvents: .TouchUpInside)
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if purchaseForm.addressArray.count < 5 {
            footView!.newAddress.frame = CGRectMake(tableView.frame.width/2-50, 15, 100, 30)
            footView!.newAddress.hidden = false
            footView!.limit.hidden = true
        }else{
            footView!.limit.frame = CGRectMake(0,0,tableView.frame.width,60)
            footView!.limit.hidden = false
            footView!.newAddress.hidden = true
        }
        return footView!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        AppDelegate.selectAddressId = purchaseForm.addressArray[indexPath.row].addressId
        if self.presentingViewController == nil {
            self.navigationController?.popViewControllerAnimated(true)
            //调用UINavigationController的popViewControllerAnimated方法退出
        }else {
            self.dismissViewControllerAnimated(true, completion: nil)
            //调用dismissViewControllerAnimated方法退出；
        }
    }
    
    //MARK: 初始化视图
    func setView() {
        self.title = "选择地址"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 96
        footView = SelectAddressFootView(reuseIdentifier: "footView")
        footView!.newAddress.addTarget(self, action: #selector(newAddress), forControlEvents: .TouchUpInside)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
    }
    
    //MARK: Action & Network
    func newAddress() {
        let alert = UIAlertController(title: "请稍等", message: nil, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            var response = Alamofire.request(.GET, "http://shop.oabc.cc:88/zgMBFrontShopV2/ShoppingConfirm.aspx").responseStringSync()
            let html = (response.result.value)!
            let nsHtml = html as NSString
            let regular = try! NSRegularExpression(pattern: "__VIEWSTATE\" value=\"(.*?)\".*?__EVENTVALIDATION\" value=\"(.*?)\"", options:.DotMatchesLineSeparators)
            let results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(0, html.characters.count))
            response = Alamofire.request(.POST, "http://shop.oabc.cc:88/zgMBFrontShopV2/ShoppingConfirm.aspx",parameters: [
                "__VIEWSTATE":nsHtml.substringWithRange(results[0].rangeAtIndex(1)),
                "__EVENTVALIDATION":nsHtml.substringWithRange(results[0].rangeAtIndex(2)),
                "ctl00$ContentPlaceHolder1$Chk_AddNewAddr":"on"
                ]).responseStringSync()
            dispatch_async(dispatch_get_main_queue(), {
                let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditAddress") as! EditAddressViewController
                viewController.hidesBottomBarWhenPushed = true
                viewController.purchaseForm = OabcApi.parsePurchaseForm(response.result.value!)
                alert.dismissViewControllerAnimated(false, completion: {
                    self.navigationController?.showViewController(viewController, sender: nil)
                })
            })
        })
    }
    
    func editAddress (sender: UIButton) {
        var uiview = sender as UIView
        while (!uiview.isKindOfClass(SelectAddressCell)) {
            uiview = uiview.superview!
        }
        let cell = uiview as! SelectAddressCell
        let alert = UIAlertController(title: "请稍等", message: nil, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            var response = Alamofire.request(.GET, "http://shop.oabc.cc:88/zgMBFrontShopV2/ShoppingConfirm.aspx").responseStringSync()
            let html = (response.result.value)!
            let nsHtml = html as NSString
            let regular = try! NSRegularExpression(pattern: "__VIEWSTATE\" value=\"(.*?)\".*?__EVENTVALIDATION\" value=\"(.*?)\"", options:.DotMatchesLineSeparators)
            let results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(0, html.characters.count))
            let indexString = cell.index < 10 ? "0\(cell.index)" : "\(cell.index)"
            response = Alamofire.request(.POST, "http://shop.oabc.cc:88/zgMBFrontShopV2/ShoppingConfirm.aspx",parameters: [
                "__VIEWSTATE":nsHtml.substringWithRange(results[0].rangeAtIndex(1)),
                "__EVENTVALIDATION":nsHtml.substringWithRange(results[0].rangeAtIndex(2)),
                "ctl00$ContentPlaceHolder1$RPT1$ctl\(indexString)$BTN_Edit":"修改"
                ]).responseStringSync()
            dispatch_async(dispatch_get_main_queue(), {
                let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditAddress") as! EditAddressViewController
                viewController.hidesBottomBarWhenPushed = true
                viewController.purchaseForm = OabcApi.parsePurchaseForm(response.result.value!)
                alert.dismissViewControllerAnimated(false, completion: {
                    self.navigationController?.showViewController(viewController, sender: nil)
                })
            })
        })
    }
    
    func deleteAddress (sender: UIButton) {
        var uiview = sender as UIView
        while (!uiview.isKindOfClass(SelectAddressCell)) {
            uiview = uiview.superview!
        }
        let cell = uiview as! SelectAddressCell
        let alert = UIAlertController(title: "删除以下地址？", message: "\(purchaseForm.addressArray[cell.index].completeAddress)\n\(purchaseForm.addressArray[cell.index].completeContact)", preferredStyle: .Alert)
        let cancelAlertAction:UIAlertAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        let sureAlertAction:UIAlertAction = UIAlertAction(title: "确认", style: .Default) { (sureButton) -> Void in
            let alert = UIAlertController(title: "请稍等", message: nil, preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                var response = Alamofire.request(.GET, "http://shop.oabc.cc:88/zgMBFrontShopV2/ShoppingConfirm.aspx").responseStringSync()
                let html = (response.result.value)!
                let nsHtml = html as NSString
                let regular = try! NSRegularExpression(pattern: "__VIEWSTATE\" value=\"(.*?)\".*?__EVENTVALIDATION\" value=\"(.*?)\"", options:.DotMatchesLineSeparators)
                let results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(0, html.characters.count))
                let indexString = cell.index < 10 ? "0\(cell.index)" : "\(cell.index)"
                response = Alamofire.request(.POST, "http://shop.oabc.cc:88/zgMBFrontShopV2/ShoppingConfirm.aspx",parameters: [
                    "__VIEWSTATE":nsHtml.substringWithRange(results[0].rangeAtIndex(1)),
                    "__EVENTVALIDATION":nsHtml.substringWithRange(results[0].rangeAtIndex(2)),
                    "ctl00$ContentPlaceHolder1$RPT1$ctl\(indexString)$BTN_Delete":"删除"
                    ]).responseStringSync()
                dispatch_async(dispatch_get_main_queue(), {
                    self.purchaseForm = OabcApi.parsePurchaseForm(response.result.value!)
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    self.tableView.reloadData()
                })
            })
        }
        alert.addAction(cancelAlertAction)
        alert.addAction(sureAlertAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

//MARK:tableView
class SelectAddressFootView:UITableViewHeaderFooterView {
    let limit = UILabel()
    let newAddress = UIButton()
    
    override init(reuseIdentifier: String?){
        super.init(reuseIdentifier: reuseIdentifier)
        limit.textAlignment = .Center
        limit.text = "您最多可以添加5个地址"
        addSubview(limit)
        newAddress.setTitle("新增地址", forState: .Normal)
        newAddress.backgroundColor = MyColor.buttonBg
        addSubview(newAddress)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
