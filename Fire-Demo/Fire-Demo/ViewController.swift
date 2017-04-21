//
//  ViewController.swift
//  Fire-Demo
//
//  Created by Meniny on 2016-04-19.
//  Copyright © 2016 Meniny. All rights reserved.
//

import UIKit
//import Fire

class ViewController: UIViewController {
    
    let BASEURL = "http://yourdomain.com/"
    let GETURL = "http://meniny.cn/blogroll.json"
    let POSTURL = "http://yourdomain.com/post.php"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        get()
    }
    
    func get() {
        let f = Fire.build(HTTPMethod: .GET, url: GETURL)
            .setParams(["l": "zh"])
            .onError { (error) in
                print(error)
        }
        f.fire { (json, resp) in
            print(json.rawValue)
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            ViewController.cancelTask(f)
        }
    }
    
    class func cancelTask(_ f: Fire) {
        f.cancel {
            print("Canceled - \(f.fireManager.request)")
        }
    }
    
    func post() {
        Fire.build(HTTPMethod: .POST, url: POSTURL, params: ["l": "zh"], timeout: 0)
            .onError { (error) in
                print(error)
            }
            .fireForJSON { (json, resp) in
                print(json.rawValue)
        }
    }
    
    func header() {
        Fire.build(HTTPMethod: .GET, url: GETURL)
            .setHTTPHeaders(["Agent": "Demo-App"])
            .setParams(["l": "zh"])
            .onError { (error) in
                print(error)
            }
            .fireForJSON { (json, resp) in
                print(json.rawValue)
        }
    }
    
    func simple() {
        Fire.get(GETURL, params: ["l": "zh"], timeout: 0, callback: { (json, resp) in
            print(json.rawValue)
        }) { (error) in
            print(error)
        }
    }
    
    func fireAPI() {
        FireAPI.baseURL = BASEURL
        let api = FireAPI(appending: "get.php", HTTPMethod: .GET, successCode: .success)
        Fire.requestFor(api, params: [:], timeout: 0, callback: { (json, resp) in
            if resp != nil && resp?.statusCode == api.successCode.rawValue {
                print(json.rawValue)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
