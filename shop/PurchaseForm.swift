//
//  PurchaseForm.swift
//  shop
//
//  Created by goupigao on 16/9/4.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import Foundation

class PurchaseForm {
    var addressArray = Array<Address>()
    var selectAddressId:Int?
    var timeArray = Array<String>()
    var selectTime = ""
    var cartArray = Array<Cart>()
    var totalPrice = 0.0
    var viewState = ""
    var eventValidation = ""
    var name = ""
    var province = ""
    var provinceArray = Array<String>()
    var city = ""
    var cityArray = Array<String>()
    var zone = ""
    var zoneArray = Array<String>()
    var address = ""
    var mobile = ""
    var phone = ""
    var isExistAddress:Bool?
    var editAddressResult = ""
    var orderResult = ""
    var cardMoney = 0.0
    var deliveryTime = ""
    var orderNo = ""
    
    func getAddressIndexById(addressId:Int) -> Int? {
        for index in 0..<addressArray.count {
            if addressArray[index].addressId == addressId {
                return index
            }
        }
        return nil
    }
}