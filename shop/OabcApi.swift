//
//  OabcApi.swift
//  shop
//
//  Created by goupigao on 16/8/31.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import Foundation

class OabcApi {
    
    static func parsePurchaseForm(html: String) -> PurchaseForm {
        let purchaseForm = PurchaseForm()
        let nsHtml = html as NSString
        var rangeStart = 0
        //获取viewState和eventValidation
        var regular = try! NSRegularExpression(pattern: "__VIEWSTATE\" value=\"(\\S*?)\".*?__EVENTVALIDATION\" value=\"(\\S*?)\"", options:.DotMatchesLineSeparators)
        var results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(rangeStart, html.characters.count-rangeStart))
        purchaseForm.viewState = nsHtml.substringWithRange(results[0].rangeAtIndex(1))
        purchaseForm.eventValidation = nsHtml.substringWithRange(results[0].rangeAtIndex(2))
        rangeStart = results[0].range.location + results[0].range.length
        //regular = try! NSRegularExpression(pattern: "ContentPlaceHolder1_UcCmmDeliverOK_LBL_CardMoney\">([\\s\\S]*?)</span>[\\s\\S]*?ContentPlaceHolder1_UcCmmDeliverOK_LBL_Date\">([\\s\\S]*?)</span>[\\s\\S]*?ContentPlaceHolder1_UcCmmDeliverOK_LBL_Number\">([\\s\\S]*?)</span>", options:.CaseInsensitive)
        regular = try! NSRegularExpression(pattern: "ContentPlaceHolder1_UcCmmDeliverOK_LBL_CardMoney\">([\\s\\d\\.]*?)</span>.*?ContentPlaceHolder1_UcCmmDeliverOK_LBL_Date\">([\\s\\d-]*?)</span>.*?ContentPlaceHolder1_UcCmmDeliverOK_LBL_Number\">([\\s\\d]*?)</span>", options:.DotMatchesLineSeparators)
        results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(rangeStart, html.characters.count-rangeStart))
        if results.count > 0 {//已经下单成功
            purchaseForm.cardMoney = (nsHtml.substringWithRange(results[0].rangeAtIndex(1)) as NSString).doubleValue
            purchaseForm.deliveryTime = nsHtml.substringWithRange(results[0].rangeAtIndex(2))
            purchaseForm.orderNo = nsHtml.substringWithRange(results[0].rangeAtIndex(3))
        }else{//还在下单页面
            regular = try! NSRegularExpression(pattern: "class=\"ul_order_Address\">(.*?)ContentPlaceHolder1_Chk_AddNewAddr(.*?)td8\">使用新地址(.*?)class=\"order_title\">确认配送时间(.*?)</select>.*?小计</span></th>(.*?)ContentPlaceHolder1_Label_Total\">([\\s\\d\\.]*?)</span>.*?ContentPlaceHolder1_Btn_ConfirmOrder(.*?)</table>", options:.DotMatchesLineSeparators)
            results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(rangeStart, html.characters.count-rangeStart))
            let addressListHTML = nsHtml.substringWithRange(results[0].rangeAtIndex(1))
            let nsAddressListHTML = addressListHTML as NSString
            purchaseForm.isExistAddress = nsHtml.substringWithRange(results[0].rangeAtIndex(2)).containsString("checked") ? false : true//检测是新增还是修改地址
            let editAddressHTML = nsHtml.substringWithRange(results[0].rangeAtIndex(3))
            let nsEditAddressHTML = editAddressHTML as NSString
            let timeListHTML = nsHtml.substringWithRange(results[0].rangeAtIndex(4))
            let nsTimeListHTML = timeListHTML as NSString
            let goodListHTML = nsHtml.substringWithRange(results[0].rangeAtIndex(5))
            let nsGoodListHTML = goodListHTML as NSString
            purchaseForm.totalPrice = (nsHtml.substringWithRange(results[0].rangeAtIndex(6)) as NSString).doubleValue//获取总价
            let orderResultHTML = nsHtml.substringWithRange(results[0].rangeAtIndex(7))
            //获取“地址列表”及“选中的地址”
            regular = try! NSRegularExpression(pattern: "name=\"rbnSelectedAddress\" value=\"(\\d+)\"(.*?)LBL_Address_\\d+\">(.*?)</span>.*?LBL_Info_\\d+\">(.*?)</span>", options:.DotMatchesLineSeparators)
            results = regular.matchesInString(addressListHTML, options: .ReportProgress , range: NSMakeRange(0, addressListHTML.characters.count))
            for result in results {
                let address = Address()
                address.addressId = (nsAddressListHTML.substringWithRange(result.rangeAtIndex(1)) as NSString).integerValue
                if nsAddressListHTML.substringWithRange(result.rangeAtIndex(2)).containsString("checked") {
                    purchaseForm.selectAddressId = address.addressId
                }
                address.completeAddress = nsAddressListHTML.substringWithRange(result.rangeAtIndex(3))
                address.completeContact = nsAddressListHTML.substringWithRange(result.rangeAtIndex(4))
                purchaseForm.addressArray.append(address)
            }
            if AppDelegate.selectAddressId != nil {
                if purchaseForm.getAddressIndexById(AppDelegate.selectAddressId!) == nil {
                    AppDelegate.selectAddressId = nil
                }
            }
            if AppDelegate.selectAddressId == nil && purchaseForm.selectAddressId != nil {
                AppDelegate.selectAddressId = purchaseForm.selectAddressId
            }
            //获取编辑或新增地址时的默认值
            if nsEditAddressHTML.containsString("tb_order_addressCheck checkOff") {
                var tempRangeStart = 0
                //获取收件人姓名
                regular = try! NSRegularExpression(pattern: "\\$TBX_Name\" type=\"text\" value=\"(.*?)\" id=\"ContentPlaceHolder1_ucReceiverAddrEdit1_TBX_Name", options:.DotMatchesLineSeparators)
                results = regular.matchesInString(editAddressHTML, options: .ReportProgress , range: NSMakeRange(tempRangeStart, editAddressHTML.characters.count-tempRangeStart))
                if results.count > 0 {
                    tempRangeStart = results[results.count-1].range.location + results[results.count-1].range.length
                    purchaseForm.name = nsEditAddressHTML.substringWithRange(results[0].rangeAtIndex(1))
                }
                //获取省份列表及选中的省份
                regular = try! NSRegularExpression(pattern: "pcz\\$DDL_Province(.*?)</select>", options:.DotMatchesLineSeparators)
                results = regular.matchesInString(editAddressHTML, options: .ReportProgress , range: NSMakeRange(tempRangeStart, editAddressHTML.characters.count-tempRangeStart))
                var selectHtml = nsEditAddressHTML.substringWithRange(results[0].rangeAtIndex(1))
                tempRangeStart = results[0].range.location + results[0].range.length
                regular = try! NSRegularExpression(pattern: "<option(.*?)value=\"(.*?)\"", options:.DotMatchesLineSeparators)
                results = regular.matchesInString(selectHtml, options: .ReportProgress , range: NSMakeRange(0, selectHtml.characters.count))
                for result in results {
                    if (selectHtml as NSString).substringWithRange(result.rangeAtIndex(1)).containsString("selected") {
                        purchaseForm.province = (selectHtml as NSString).substringWithRange(result.rangeAtIndex(2))
                    }
                    purchaseForm.provinceArray.append((selectHtml as NSString).substringWithRange(result.rangeAtIndex(2)))
                }
                //获取城市列表及选中的城市
                regular = try! NSRegularExpression(pattern: "pcz\\$sel_city(.*?)</select>", options:.DotMatchesLineSeparators)
                results = regular.matchesInString(editAddressHTML, options: .ReportProgress , range: NSMakeRange(tempRangeStart, editAddressHTML.characters.count-tempRangeStart))
                selectHtml = nsEditAddressHTML.substringWithRange(results[0].rangeAtIndex(1))
                tempRangeStart = results[0].range.location + results[0].range.length
                regular = try! NSRegularExpression(pattern: "<option(.*?)value=\"(.*?)\"", options:.DotMatchesLineSeparators)
                results = regular.matchesInString(selectHtml, options: .ReportProgress , range: NSMakeRange(0, selectHtml.characters.count))
                for result in results {
                    if (selectHtml as NSString).substringWithRange(result.rangeAtIndex(1)).containsString("selected") {
                        purchaseForm.city = (selectHtml as NSString).substringWithRange(result.rangeAtIndex(2))
                    }
                    purchaseForm.cityArray.append((selectHtml as NSString).substringWithRange(result.rangeAtIndex(2)))
                }
                //获取区县列表及选中的区县
                regular = try! NSRegularExpression(pattern: "pcz\\$sel_zone(.*?)</select>", options:.DotMatchesLineSeparators)
                results = regular.matchesInString(editAddressHTML, options: .ReportProgress , range: NSMakeRange(tempRangeStart, editAddressHTML.characters.count-tempRangeStart))
                selectHtml = nsEditAddressHTML.substringWithRange(results[0].rangeAtIndex(1))
                tempRangeStart = results[0].range.location + results[0].range.length
                regular = try! NSRegularExpression(pattern: "<option(.*?)value=\"(.*?)\"", options:.DotMatchesLineSeparators)
                results = regular.matchesInString(selectHtml, options: .ReportProgress , range: NSMakeRange(0, selectHtml.characters.count))
                for result in results {
                    if (selectHtml as NSString).substringWithRange(result.rangeAtIndex(1)).containsString("selected") {
                        purchaseForm.zone = (selectHtml as NSString).substringWithRange(result.rangeAtIndex(2))
                    }
                    purchaseForm.zoneArray.append((selectHtml as NSString).substringWithRange(result.rangeAtIndex(2)))
                }
                //获取地址详情
                regular = try! NSRegularExpression(pattern: "\\$TBX_Address\" type=\"text\" value=\"(.*?)\" id=\"ContentPlaceHolder1_ucReceiverAddrEdit1_TBX_Address", options:.DotMatchesLineSeparators)
                results = regular.matchesInString(editAddressHTML, options: .ReportProgress , range: NSMakeRange(tempRangeStart, editAddressHTML.characters.count-tempRangeStart))
                if results.count > 0 {
                    tempRangeStart = results[0].range.location + results[0].range.length
                    purchaseForm.address = nsEditAddressHTML.substringWithRange(results[0].rangeAtIndex(1))
                }
                //获取手机号码
                regular = try! NSRegularExpression(pattern: "\\$TBX_Mobile\" type=\"text\" value=\"(.*?)\" id=\"ContentPlaceHolder1_ucReceiverAddrEdit1_TBX_Mobile", options:.DotMatchesLineSeparators)
                results = regular.matchesInString(editAddressHTML, options: .ReportProgress , range: NSMakeRange(tempRangeStart, editAddressHTML.characters.count-tempRangeStart))
                if results.count > 0 {
                    tempRangeStart = results[0].range.location + results[0].range.length
                    purchaseForm.mobile = nsEditAddressHTML.substringWithRange(results[0].rangeAtIndex(1))
                }
                //获取固定电话
                regular = try! NSRegularExpression(pattern: "\\$TBX_Phone\" type=\"text\" value=\"(.*?)\" id=\"ContentPlaceHolder1_ucReceiverAddrEdit1_TBX_Phone", options:.DotMatchesLineSeparators)
                results = regular.matchesInString(editAddressHTML, options: .ReportProgress , range: NSMakeRange(tempRangeStart, editAddressHTML.characters.count-tempRangeStart))
                if results.count > 0 {
                    tempRangeStart = results[0].range.location + results[0].range.length
                    purchaseForm.phone = nsEditAddressHTML.substringWithRange(results[0].rangeAtIndex(1))
                }
                //获取编辑或新增地址的操作返回值
                regular = try! NSRegularExpression(pattern: "ContentPlaceHolder1_LBL_Message\".*?Red.*?>(.*?)</", options:.DotMatchesLineSeparators)
                results = regular.matchesInString(editAddressHTML, options: .ReportProgress , range: NSMakeRange(tempRangeStart, editAddressHTML.characters.count-tempRangeStart))
                if results.count > 0 {
                    purchaseForm.editAddressResult = nsEditAddressHTML.substringWithRange(results[0].rangeAtIndex(1))
                }
            }
            //获取配送日期列表及选中的配送日期
            regular = try! NSRegularExpression(pattern: "<option(.*?)>([\\d-\\s]+?星期.+?)</option>", options:.DotMatchesLineSeparators)
            results = regular.matchesInString(timeListHTML, options: .ReportProgress , range: NSMakeRange(0, timeListHTML.characters.count))
            for result in results {
                if nsTimeListHTML.substringWithRange(result.rangeAtIndex(1)).containsString("selected") {
                    purchaseForm.selectTime = nsTimeListHTML.substringWithRange(result.rangeAtIndex(2))
                }
                purchaseForm.timeArray.append(nsTimeListHTML.substringWithRange(result.rangeAtIndex(2)))
            }
            if AppDelegate.selectTime != nil && !purchaseForm.timeArray.contains(AppDelegate.selectTime!) {
                AppDelegate.selectTime = nil
            }
            if AppDelegate.selectTime == nil {
                AppDelegate.selectTime = purchaseForm.selectTime
            }
            //获取产品列表
            regular = try! NSRegularExpression(pattern: "<tr>\\s*?<td>[\\s\\d]*?</td>\\s*?<td>(.*?)</td>\\s*?<td>(.*?)</td>.*?￥([\\s\\d\\.]*?)</td>\\s*?<td>([\\s\\d]*?)</td>\\s*?<td>.*?</tr>", options:.DotMatchesLineSeparators)
            results = regular.matchesInString(goodListHTML, options: .ReportProgress , range: NSMakeRange(0, goodListHTML.characters.count))
            for result in results {
                let cart = Cart()
                cart.name = nsGoodListHTML.substringWithRange(result.rangeAtIndex(1)).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                cart.guige = nsGoodListHTML.substringWithRange(result.rangeAtIndex(2))
                cart.couponPrice = (nsGoodListHTML.substringWithRange(result.rangeAtIndex(3)) as NSString).doubleValue
                cart.count = (nsGoodListHTML.substringWithRange(result.rangeAtIndex(4)) as NSString).integerValue
                purchaseForm.cartArray.append(cart)
            }
            //获取下单的返回值
            regular = try! NSRegularExpression(pattern: "ContentPlaceHolder1_LBL_Msg\".*?Red.*?>(.*?)</", options:.DotMatchesLineSeparators)
            results = regular.matchesInString(orderResultHTML, options: .ReportProgress , range: NSMakeRange(0, orderResultHTML.characters.count))
            if results.count > 0 {
                purchaseForm.orderResult = (orderResultHTML as NSString).substringWithRange(results[0].rangeAtIndex(1))
            }
        }
        
        return purchaseForm
    }
    
}