//
//  FireDemo.swift
//  Fire-Demo
//
//  Created by Meniny on 2017-04-23.
//  Copyright © 2017年 Meniny. All rights reserved.
//

import Foundation
import Fire

open class FireDemo {
    static var BASEURL = "http://yourdomain.com/"
    static var GETURL = "http://meniny.cn/blogroll.json"
    static var POSTURL = "http://yourdomain.com/post.php"
    
    open class func get() {
        let f = Fire.build(HTTPMethod: .GET, url: FireDemo.GETURL)
            .setParams(["l": "zh"])
            .onError { (error) in
                print(error)
        }
        f.fire { (json, resp) in
            print(json.rawValue)
        }
//        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
//            FireDemo.cancelTask(f)
//        }
    }
    
    open class func cancelTask(_ f: Fire) {
        f.cancel {
            print("Canceled - \(f.fireManager.request)")
        }
    }
    
    open class func post() {
        Fire.build(HTTPMethod: .POST, url: FireDemo.POSTURL, params: ["l": "zh"], timeout: 0)
            .onError { (error) in
                print(error)
            }
            .fireForJSON { (json, resp) in
                print(json.rawValue)
        }
    }
    
    open class func header() {
        Fire.build(HTTPMethod: .GET, url: FireDemo.GETURL)
            .setHTTPHeaders(["Agent": "Demo-App"])
            .setParams(["l": "zh"])
            .onError { (error) in
                print(error)
            }
            .fireForJSON { (json, resp) in
                print(json.rawValue)
        }
    }
    
    open class func simple() {
        Fire.get(FireDemo.GETURL, params: ["l": "zh"], timeout: 0, callback: { (json, resp) in
            print(json.rawValue)
        }) { (error) in
            print(error)
        }
    }
    
    open class func fireAPI() {
        FireAPI.baseURL = FireDemo.BASEURL
        let api = FireAPI(appending: "get.php", HTTPMethod: .GET, successCode: .success)
        Fire.requestFor(api, params: [:], timeout: 0, callback: { (json, resp) in
            if resp != nil && resp?.statusCode == api.successCode.rawValue {
                print(json.rawValue)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
