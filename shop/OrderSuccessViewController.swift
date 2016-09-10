//
//  OrderSuccessViewController.swift
//  shop
//
//  Created by goupigao on 16/9/9.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit

class OrderSuccessViewController: UIViewController {
    @IBOutlet weak var cardMoney: UILabel!
    @IBOutlet weak var deliveryTime: UILabel!
    @IBOutlet weak var orderNo: UILabel!
    
    var purchaseForm = PurchaseForm()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "产品订购成功"
        cardMoney.text = "卡内余额：￥\(purchaseForm.cardMoney)"
        deliveryTime.text = "预计配送时间：\(purchaseForm.deliveryTime)"
        orderNo.text = "订单号：\(purchaseForm.orderNo)"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
        var viewControllers = (self.navigationController?.viewControllers)!
        viewControllers = viewControllers.filter() { !$0.isKindOfClass(PurchaseViewController) }
        self.navigationController?.setViewControllers(viewControllers, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func viewOrder(sender: AnyObject) {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("Order") as! OrderViewController
        viewController.hidesBottomBarWhenPushed = true
        viewController.viewState = self.purchaseForm.viewState
        viewController.eventValidation = self.purchaseForm.eventValidation
        self.navigationController?.showViewController(viewController, sender: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
