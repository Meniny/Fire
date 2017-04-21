
<p align="center">
  <img src="https://ooo.0o0.ooo/2017/04/20/58f8c55fe196b.png" alt="Fire">
</p>

## What's this?

Fire is a HTTP/HTTPS networking framework written in Swift for people to read, and incidentally for machines to execute :).

## Requirements

* iOS 8.0+
* macOS 10.10+ (v1.1.2+)
* Xcode 8 with Swift 3

## Installation

#### CocoaPods

```ruby
pod 'Fire'
```

#### Manually: Framework

First, excute this:

```bash
git submodule add https://github.com/Meniny/Fire-in-Swift.git
```

then:

* Drag `Fire/Fire.xcodeproj` into your project
* Go to `PROJECT`->`TARGETS`->[YOUR_TARGET_NAME]->`General`->`Embedded Binaries`
* Click `＋`
* Select `Fire.frameWork`, click `Add`.

#### Manually: Source Files

Copy all files in the `Fire/Source` directory into your project.

## Usage (v2.0.0+)

To send a request with Fire, you need to do 3 steps.

First, build up a Fire object:

```swift
let f = Fire.build(HTTPMethod: .GET, url: "https://yourdomain.com/get?l=zh")
```

Then, config the Fire object:

```swift
f.setParams(["key": "value"])
f.setFiles([file])
f.setHTTPHeader(name: "Accept", value: "application/json")
f.setBasicAuth("user", password: "pwd!@#")
f.setHTTPBodyRaw(json.rawValue)
let certData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("FireDemo", ofType: "cer")!)!
f.setSSLPinning(localCertData: certData) {
    print("Warning: Under Man-in-the-middle attack!!")
}
f.onError({ (error) -> Void in
    print("Error: Network offline!")
})
```

Finally, fire up:

```swift
Fire.fire { (json, resp) -> Void in
    print(json["arg"]["key"].stringValue)
}

// or

Fire.fireForJSON { (json, resp) -> Void in
    print(json["arg"]["key"].stringValue)
}

// or

Fire.fireForString { (str, resp) -> Void in
    print(str)
}

// or

Fire.fireForData { (data, resp) -> Void in
    print("Success")
}
```

If you want to cancel it:

```swift
f.cancel {
   print("Canceled")
}
```

## Samples (v2.0.0+)

```swift
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
```
