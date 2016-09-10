//
//  Alamofire.swift
//  shop
//
//  Created by goupigao on 16/9/5.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import Foundation
import Alamofire

//MARK: 实现Alamofire执行同步请求
extension Alamofire.Request {
    public func responseStringSync(encoding encoding: NSStringEncoding? = nil) -> Response<String, NSError> {
        let semaphore = dispatch_semaphore_create(0)
        var result: Response<String, NSError>!
        self.responseString(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), encoding: encoding, completionHandler: { response in
            result = response
            dispatch_semaphore_signal(semaphore)
        })
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return result
    }
}