//
//  OrderViewController.swift
//  shop
//
//  Created by goupigao on 16/9/1.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit
import Alamofire

class OrderViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    //MARK: 属性
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var order = Order()
    var recId:Int?
    var viewState:String?
    var eventValidation:String?

    //MARK: 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        setView()
        loadOrder()
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
            return order.cartArray.count
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
            return "订单状态"
        case 1:
            return "收件人信息"
        case 2:
            return "配送产品列表"
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("orderOrderCell", forIndexPath: indexPath)  as! OrderOrderCell
            cell.orderNo.text = order.orderNo
            cell.orderPrice.text = "\(order.orderPrice)"
            cell.payPrice.text = "\(order.payPrice)"
            cell.createTime.text = order.createTime
            cell.deliveryTime.text = order.deliveryTime
            cell.orderState.text = order.orderState
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("orderContactCell", forIndexPath: indexPath)  as! OrderContactCell
            cell.name.text = order.name
            cell.address.text = order.address
            cell.postCode.text = order.postCode
            cell.mobile.text = order.mobile
            cell.phone.text = order.phone
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("orderCartCell", forIndexPath: indexPath)  as! OrderCartCell
            cell.name.text = order.cartArray[indexPath.row].name
            cell.guige.text = order.cartArray[indexPath.row].guige
            cell.countAndPrice.text = "\(order.cartArray[indexPath.row].count) × ￥\(order.cartArray[indexPath.row].couponPrice)"
            return cell
        default:
            return UITableViewCell(style: .Default, reuseIdentifier: "nil")
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    //MARK: Action & Network
    func setView(){
        self.title = "订单"
        tableView.backgroundColor = UIColor.clearColor()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 130
        indicator.color = MyColor.greenDark
        var viewControllers = (self.navigationController?.viewControllers)!
        viewControllers = viewControllers.filter() { !$0.isKindOfClass(OrderSuccessViewController) }
        self.navigationController?.setViewControllers(viewControllers, animated: false)
    }
    
    func loadOrder() {
        var method = Method.GET
        var parameters:[String : AnyObject]?
        var url:String?
        if recId != nil {
            url = "http://shop.oabc.cc:88/zgMBFrontShopV2/myDeliverDetail.aspx"
            parameters = ["RecID":"\(recId!)","Sure":"1"]
        }else if viewState != nil && eventValidation != nil {
            method = Method.POST
            url = "http://shop.oabc.cc:88/zgMBFrontShopV2/cmmResult.aspx"
            parameters = ["__VIEWSTATE":viewState!,"__EVENTVALIDATION":eventValidation!,"ctl00$ContentPlaceHolder1$UcCmmDeliverOK$Btn_ViewDetail.x":"75","ctl00$ContentPlaceHolder1$UcCmmDeliverOK$Btn_ViewDetail.y":"7"]
        }else{
            return
        }
        indicator.hidden = false
        indicator.startAnimating()
        Alamofire.request(method, url!,parameters: parameters!).responseString { (response) in
            guard let html = response.result.value else {
                self.hideIndicator()
                return
            }
            if response.result.error != nil {
                self.hideIndicator()
                return
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                self.order = Order()
                let nsHtml = html as NSString
                var regular = try! NSRegularExpression(pattern: "LBL_OrderNumber\">([\\s\\d]*?)</span>.*?LBL_State\">(.*?)</span>.*?LBL_DeliverDate\">([\\s\\d-]*?)</span>.*?LBL_CreateTime\">([\\s\\d-]*?)</span>.*?<th>小计</th>(.*?)</table>.*?LBL_TotalMoney1\">([\\s\\d\\.]*?)</span>.*?LBL_PayMoney\">([\\s\\d\\.]*?)</span>.*?UcReceiver_LBL_Name\">(.*?)</span>.*?LBL_Address\">(.*?)</span>.*?LBL_Postalcode\">(.*?)</span>.*?LBL_Phone\">(.*?)</span>.*?LBL_Mobile\">(.*?)</span>", options:.DotMatchesLineSeparators)
                var results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(0, html.characters.count))
                if results.count > 0 {
                    self.order.orderNo = nsHtml.substringWithRange(results[0].rangeAtIndex(1))
                    self.order.orderState = nsHtml.substringWithRange(results[0].rangeAtIndex(2))
                    self.order.deliveryTime = nsHtml.substringWithRange(results[0].rangeAtIndex(3))
                    self.order.createTime = nsHtml.substringWithRange(results[0].rangeAtIndex(4))
                    let cartListHTML = nsHtml.substringWithRange(results[0].rangeAtIndex(5))
                    let nsCartListHTML = cartListHTML as NSString
                    self.order.orderPrice = (nsHtml.substringWithRange(results[0].rangeAtIndex(6)) as NSString).doubleValue
                    self.order.payPrice = (nsHtml.substringWithRange(results[0].rangeAtIndex(7)) as NSString).doubleValue
                    self.order.name = nsHtml.substringWithRange(results[0].rangeAtIndex(8))
                    self.order.address = nsHtml.substringWithRange(results[0].rangeAtIndex(9))
                    self.order.postCode = nsHtml.substringWithRange(results[0].rangeAtIndex(10))
                    self.order.phone = nsHtml.substringWithRange(results[0].rangeAtIndex(11))
                    self.order.mobile = nsHtml.substringWithRange(results[0].rangeAtIndex(12))
                    regular = try! NSRegularExpression(pattern: "<tr>\\s*?<td>(.*?)</td>\\s*?<td>(.*?)</td>.*?￥([\\s\\d\\.]*?)元.*?<td>([\\s\\d]*?)</td>.*?</tr>", options:.DotMatchesLineSeparators)
                    results = regular.matchesInString(cartListHTML, options: .ReportProgress , range: NSMakeRange(0, cartListHTML.characters.count))
                    for result in results {
                        let cart = Cart()
                        //cart.id = 0
                        cart.name = nsCartListHTML.substringWithRange(result.rangeAtIndex(1))
                        cart.guige = nsCartListHTML.substringWithRange(result.rangeAtIndex(2))
                        cart.couponPrice = (nsCartListHTML.substringWithRange(result.rangeAtIndex(3)) as NSString).doubleValue
                        cart.count = (nsCartListHTML.substringWithRange(result.rangeAtIndex(4)) as NSString).integerValue
                        self.order.cartArray.append(cart)
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    if results.count>0 {
                        self.tableView.reloadData()
                    }
                })
                self.hideIndicator()
            }
        }
    }
    
    func hideIndicator() {
        dispatch_async(dispatch_get_main_queue(), {
            self.indicator.stopAnimating()
            self.indicator.hidden = true
        })
    }
    
    func back() {
        navigationController?.popToViewController((navigationController?.viewControllers[0])!, animated: true)
    }

}
