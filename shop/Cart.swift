//
//  Cart.swift
//  shop
//
//  Created by goupigao on 16/9/1.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import Foundation

class Cart:NSObject,NSCoding {
    var goodId:Int?
    var name = ""
    var guige = ""
    var count:Int = 0
    var couponPrice = 0.0
    //var totalPrice = 0.0
    
    override init () {
        super.init()
    }
    
    init (goodId:Int, name:String, count:Int, couponPrice:Double) {
        super.init()
        self.goodId = goodId
        self.name = name
        self.count = count
        self.couponPrice = couponPrice
    }
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("CartArray")
    
    static func clearArchive() {
        do{
            try NSFileManager.defaultManager().removeItemAtPath(ArchiveURL.path!)
        }catch{
            print("删除目录失败")
        }
    }
    
    //MARK: NSCoding
    //编码
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(goodId!, forKey: "goodId")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(guige, forKey: "guige")
        aCoder.encodeInteger(count, forKey: "count")
        aCoder.encodeDouble(couponPrice, forKey: "couponPrice")
        //aCoder.encodeDouble(totalPrice, forKey: "totalPrice")
    }
    //解码
    required init?(coder aDecoder: NSCoder) {
        goodId = aDecoder.decodeIntegerForKey("goodId")
        name = aDecoder.decodeObjectForKey("name") as! String
        guige = aDecoder.decodeObjectForKey("guige") as! String
        count = aDecoder.decodeIntegerForKey("count")
        couponPrice = aDecoder.decodeDoubleForKey("couponPrice")
        //totalPrice = aDecoder.decodeDoubleForKey("totalPrice")
    }
}