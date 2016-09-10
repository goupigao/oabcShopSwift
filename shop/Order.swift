//
//  Order.swift
//  shop
//
//  Created by goupigao on 16/8/31.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import Foundation

class Order {
    var orderNo:String = ""
    var recId:Int?
    var createTime:String = ""
    var deliveryTime:String = ""
    var orderPrice = 0.0
    var payPrice = 0.0
    var orderState:String = ""
    var name:String = ""
    var address:String = ""
    var postCode:String = ""
    var mobile:String = ""
    var phone:String = ""
    var cartArray = Array<Cart>()
}