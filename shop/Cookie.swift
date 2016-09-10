//
//  Cookie.swift
//  shop
//
//  Created by goupigao on 16/9/1.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import Foundation

class Cookie {
    static func getCookieByName(let url:String, let cookieName:String)->NSHTTPCookie? {
        let cookieArray:[NSHTTPCookie]? = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: url)!)
        var cookie:NSHTTPCookie?
        if cookieArray != nil && cookieArray!.count > 0 {
            for c in cookieArray! {
                if c.name == cookieName {
                    cookie = c
                    break
                }
            }
        }
        return cookie
    }
    static func getProvinceName() -> String? {
        return getCookieByName("http://shop.oabc.cc:88/",cookieName: "provinceName")?.value.stringByRemovingPercentEncoding
    }
    static func setProvinceName(city:String) {
        let Dic:[String:AnyObject] = [
            NSHTTPCookieDomain:"shop.oabc.cc",
            NSHTTPCookieName:"provinceName",
            NSHTTPCookieValue:city.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!,
            NSHTTPCookieExpires:NSDate(timeIntervalSinceNow: NSTimeInterval(60 * 60 * 24 * 365)),
            NSHTTPCookiePath:"/"
        ]
        let cookie = NSHTTPCookie(properties: Dic)
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie!)
    }
}