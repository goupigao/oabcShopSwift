//
//  PurchaseViewController.swift
//  shop
//
//  Created by goupigao on 16/9/3.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit
import Alamofire
import ToastSwiftFramework

class PurchaseViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,GDropDownMenuDelegate{
    //MARK: 属性
    @IBOutlet weak var tableView: UITableView!
    var gDropDownMenu = GDropDownMenu()
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: tableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return purchaseForm.cartArray.count+1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "选择配送地址"
        case 1:
            return "选择配送时间"
        case 2:
            return "配送产品信息"
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("addressCell")
            if cell == nil{
                cell = UITableViewCell(style: .Default, reuseIdentifier: "addressCell")
                cell?.textLabel?.numberOfLines = 0
            }
            if AppDelegate.selectAddressId != nil {
                let address = purchaseForm.addressArray[purchaseForm.getAddressIndexById(AppDelegate.selectAddressId!)!]
                cell?.textLabel?.text = "\(address.completeAddress)\n\(address.completeContact)"
            }else{
                cell?.textLabel?.text = "请选择收货地址"
            }
            cell?.accessoryView?.frame.size = CGSizeMake(20, 20)
            cell?.accessoryView = UIImageView(image: UIImage(named: "unfold"))
            cell?.selectionStyle = .None
            return cell!
        case 1:
            var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("timeCell")
            if cell == nil{
                cell = UITableViewCell(style: .Default, reuseIdentifier: "timeCell")
            }
            cell?.textLabel?.text = AppDelegate.selectTime
            cell?.accessoryView?.frame.size = CGSizeMake(20, 20)
            cell?.accessoryView = UIImageView(image: UIImage(named: "unfold"))
            cell?.selectionStyle = .None
            return cell!
        case 2:
            if indexPath.row == purchaseForm.cartArray.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("purchaseOrderCell", forIndexPath: indexPath)  as! PurchaseOrderCell
                cell.totalPrice.text = "总价：￥\(purchaseForm.totalPrice)"
                cell.order.addTarget(self, action: #selector(order), forControlEvents: .TouchUpInside)
                cell.selectionStyle = .None
                return cell
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("purchaseCartCell", forIndexPath: indexPath)  as! PurchaseCartCell
                cell.name.text = purchaseForm.cartArray[indexPath.row].name
                cell.guige.text = purchaseForm.cartArray[indexPath.row].guige
                cell.countAndPrice.text = "\(purchaseForm.cartArray[indexPath.row].count) × ￥\(purchaseForm.cartArray[indexPath.row].couponPrice)"
                cell.selectionStyle = .None
                return cell
            }
        default:
            return UITableViewCell(style: .Default, reuseIdentifier: "nil")
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("SelectAddress") as! SelectAddressViewController
            viewController.hidesBottomBarWhenPushed = true
            viewController.purchaseForm = purchaseForm
            self.navigationController?.showViewController(viewController, sender: nil)
        }else if indexPath.section == 1 && indexPath.row == 0 {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            let x = tableView.frame.origin.x + cell!.frame.origin.x + cell!.layoutMargins.left
            var y = tableView.frame.origin.y + cell!.frame.origin.y + cell!.frame.height - cell!.layoutMargins.bottom - tableView.contentOffset.y
            let height = (CGFloat)(purchaseForm.timeArray.count < 5 ? purchaseForm.timeArray.count*44 : 200)
            let visibleHeight = tableView.frame.height + tableView.frame.origin.y
            if y + height > visibleHeight {
                y = visibleHeight - height
            }
            gDropDownMenu.origin = CGPointMake(x, y)
            gDropDownMenu.size = CGSizeMake(250, height)
            gDropDownMenu.items = purchaseForm.timeArray
            gDropDownMenu.selectedString = AppDelegate.selectTime
            gDropDownMenu.showDropper()
            self.view.addSubview(gDropDownMenu)
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    //MARK: 下拉菜单
    func gDropDownMenuDidSelect(tag: String, index: Int) {
        AppDelegate.selectTime = purchaseForm.timeArray[index]
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 1)], withRowAnimation: .Automatic)
    }
    
    //MARK: 初始化视图
    func setView() {
        self.title = "结算"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension//cell高度自适应（self-sizing），用于Grouped的tableView
        tableView.estimatedRowHeight = 67
        gDropDownMenu.delegate = self
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
    }
    
    //MARK: Action & Network
    func order() {
        if AppDelegate.selectAddressId == nil {
            self.view.makeToast("请选择配送地址")
            return
        }
        if AppDelegate.selectTime == "" {
            self.view.makeToast("请选择配送时间")
            return
        }
        let alert = UIAlertController(title: "请稍等", message: nil, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        var parameters = ["__VIEWSTATE":purchaseForm.viewState, "__EVENTVALIDATION":purchaseForm.eventValidation, "ctl00$ContentPlaceHolder1$Btn_ConfirmOrder.x":"52", "ctl00$ContentPlaceHolder1$Btn_ConfirmOrder.y":"21"]
        parameters["ctl00$ContentPlaceHolder1$HDF_SelConsigneeRecID"] = "\(AppDelegate.selectAddressId!)"
        parameters["rbnSelectedAddress"] = "\(AppDelegate.selectAddressId!)"
        parameters["ctl00$ContentPlaceHolder1$DDL_Date"] = (AppDelegate.selectTime! as NSString).substringWithRange(NSMakeRange(0, 10))
        Alamofire.request(.POST, "http://shop.oabc.cc:88/zgMBFrontShopV2/ShoppingConfirm.aspx",parameters: parameters).responseString { (response) in
            guard let html = response.result.value else {
                alert.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            if response.result.error != nil {
                alert.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            self.purchaseForm = OabcApi.parsePurchaseForm(html)
            dispatch_async(dispatch_get_main_queue(), {
                if self.purchaseForm.orderResult != "" {
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    self.view.makeToast(self.purchaseForm.orderResult)
                    self.tableView.reloadData()
                }else{
                    Cart.clearArchive()
                    let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("OrderSuccess") as! OrderSuccessViewController
                    viewController.hidesBottomBarWhenPushed = true
                    viewController.purchaseForm = self.purchaseForm
                    alert.dismissViewControllerAnimated(false, completion: {
                        self.navigationController?.showViewController(viewController, sender: nil)
                    })
                }
            })
        }
    }
    
}
