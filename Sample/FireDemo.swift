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
    static var BASEURL = "http://your-domain.com/"
    static var GETURL = "http://meniny.cn/docs.json"
    static var POSTURL = "http://your-domain.com/post.php"
    
    open class func get() {
        FireDefaults.DEBUG = true
        Fire.async(HTTPMethod: .GET, url: FireDemo.GETURL, prependBaseURL: false, params: ["l": "zh"], callback: { (json, resp) in
//            print(json.rawValue)
        }) { (_, error) in
            print(error)
        }
//        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
//            FireDemo.cancelTask(f)
//        }
    }
    
    open class func cancelTask(_ f: Fire) {
        f.cancel {
            print("Canceled \(f)")
        }
    }
    
    open class func post() {
        Fire.build(HTTPMethod: .POST, url: FireDemo.POSTURL, prependBaseURL: false, params: ["l": "zh"], timeout: 0)
            .onError { (_, error) in
                print(error)
            }.fireForJSON { (json, resp) in
                
        }
    }
    
    open class func header() {
        Fire.build(HTTPMethod: .GET, url: FireDemo.GETURL, prependBaseURL: false)
            .setHTTPHeaders(["Agent": "Demo-App"])
            .setParams(["l": "zh"])
            .onError { (_, error) in
                print(error)
            }.fireForJSON { (json, resp) in
//                print(json.rawValue)
        }
    }
    
    open class func simple() {
        Fire.get(FireDemo.GETURL, prependBaseURL: false, params: ["l": "zh"], timeout: 0, callback: { (json, resp) in
            print(json.rawValue)
        }) { (_, error) in
            print(error)
        }
    }
    
    open class func FireAPI1() {
        Fire.API.baseURL = FireDemo.BASEURL
        let api = Fire.API(appending: "get.php", HTTPMethod: .GET, successCode: .success)
        Fire.request(api: api, params: [:], timeout: 0, callback: { (json, resp) in
            if let status = resp?.statusCode {
                if status == api.successCode.rawValue {
                    // ...
                }
            }
        }) { (_, error) in
            print(error.localizedDescription)
        }
    }
    
    open class func FireAPI2() {
        Fire.API.baseURL = FireDemo.BASEURL
        let api = Fire.API(appending: "get.php", HTTPMethod: .GET, successCode: .success)
        api.requestJSON(params: ["user": "Elias"], callback: { (json, resp) in
            if let status = resp?.statusCode {
                if status == api.successCode.rawValue {
                    // ...
                }
            }
        }) { (_, error) in
            print(error.localizedDescription)
        }
    }
    
    open class func FireAPI3() {
        Fire.API.baseURL = FireDemo.BASEURL
        let api = Fire.API(appending: "get.php", HTTPMethod: .GET, headers: ["Content-Type": "text/json"], successCode: .success)
        api.requestJSON(params: ["userid": "1232"], headers: ["Device": "iOS"], timeout: 60, dispatch: .asynchronously, callback: { (json, resp) in
            if let status = resp?.statusCode {
                if status == api.successCode.rawValue {
                    // ...
                }
            }
        }) { (_, error) in
            print(error.localizedDescription)
        }
    }
    
    open class func escape() {
        FireDefaults.baseURL = FireDemo.BASEURL
        let u = "/abc 123/中文/def.json"
        let p: Fire.Params = ["姓名": "ÔÓ"]
        Fire.get(u, params: p, callback: nil, onError: nil)
        Fire.build(HTTPMethod: .POST, url: u, prependBaseURL: true, params: p, timeout: 60, dispatch: .asynchronously)
            .fire { (json, resp) in
                
            }.onError { (_, error) in
                
        }
    }
    
    open class func upload() {
        let imgPath = "/Users/Meniny/Desktop/Jsonify.png"
        let name = "smfile"
        let ext = "png"
        let mime = "image/png"
        let toURL = "https://sm.ms/api/upload/"
        let params = ["format": "json", "ssl": "1"]
        if let data = try? Data(contentsOf: URL(fileURLWithPath: imgPath)) {
            Fire.upload(data: data,
                        name: name,
                        ext: ext,
                        mimeType: mime,
                        toURL: toURL,
                        params: params,
                        timeout: 200,
                        progress: { (sent, total, progress) in
                            print(String(format: "%0.2f", progress) + "%")
            }, callback: { (json, resp) in
                let success = json["code"].stringValue
                if success == "success" {
                    print(json["data"]["url"].stringValue)
                } else {
                    print(json["msg"].stringValue)
                }
            }) { (_, error) in
                print(error.localizedDescription)
            }
        }
    }
}
