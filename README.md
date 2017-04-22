
<p align="center">
  <img src="https://ooo.0o0.ooo/2017/04/22/58fac03652695.png" alt="Fire">
</p>

* [English Introduction](#Introduction)
* [中文介绍](#中文介绍)

# Introduction

## What's this?

Fire is a delightful HTTP/HTTPS networking framework for iOS/macOS platform written in Swift for humans to read, and incidentally for machines to execute :).

## Features

- [x] Chainable Request / Response Methods
- [x] Upload File / Data / MultipartFormData
- [x] HTTP Basic Authorization
- [x] TLS Certificate and Public Key Pinning
- [x] Comprehensive Unit and Integration Test Coverage
- [x] Asynchronous Request
- [x] Timeouts
- [x] form (`x-www-form-encoded`)/JSON HTTP body

## Requirements

* iOS 8.0+
* macOS 10.10+ (Fire 1.1.2+)
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

* Drag `Fire-in-Swift/Fire/Fire.xcodeproj` into your project
* Go to `PROJECT`->`TARGETS`->[YOUR_TARGET_NAME]->`General`->`Embedded Binaries`
* Click `＋`
* Select `Fire.frameWork`/`FireOSX.frameWork`, click `Add`

![Manaually](https://ooo.0o0.ooo/2017/04/22/58fabbe9abe44.jpg)

#### Manually: Source Files

Copy all files in the `Fire/Source` directory into your project.

## Contribution

You are welcome to fork and submit pull requests.

## License

Fire is open-sourced software, licensed under the `MIT` license.

## Usage

To send a request with Fire, you need to do 3 steps.

First, build up a Fire object:

```swift
let f = Fire.build(HTTPMethod: .GET, url: "https://yourdomain.com/get?l=zh")
```

Then, config the Fire object:

```swift
f.setParams(["key": "value"])
f.setFiles([file])
f.setHTTPHeaders(["Accept": "application/json"])
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

## Samples

```swift
//
//  ViewController.swift
//  Fire-Demo
//
//  Created by Meniny on 2016-04-19.
//  Copyright © 2016 Meniny. All rights reserved.
//

import UIKit
import Fire

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

# 中文介绍

## 这是什么?

Fire 一个轻量级的 HTTP/HTTPS 网络框架。用 Swift 书写，碰巧可以运行 :)

## 特性

- [x] 链式调用的请求和响应方法
- [x] 上传文件和数据
- [x] 支持 HTTP Basic 认证
- [x] 支持 SSL Pinning
- [x] 全面的单元和集成测试覆盖
- [x] 异步请求
- [x] 超时
- [x] 支持 form (`x-www-form-encoded`)/JSON HTTP 请求体

## 环境

* iOS 8.0+
* macOS 10.10+ (Fire 1.1.2+)
* Xcode 8 及 Swift 3

## 安装

#### CocoaPods

```ruby
pod 'Fire'
```

#### 手动安装: 框架

首先执行这条指令:

```bash
git submodule add https://github.com/Meniny/Fire-in-Swift.git
```

然后:

* 将 `Fire-in-Swift/Fire/Fire.xcodeproj` 拖入你的项目
* 定位到 `PROJECT`->`TARGETS`->[YOUR_TARGET_NAME]->`General`->`Embedded Binaries`
* 点击 `＋`
* 选择 `Fire.frameWork`/`FireOSX.frameWork` 后点击 `Add`

![Manaually](https://ooo.0o0.ooo/2017/04/22/58fabbe9abe44.jpg)

#### 手动安装: 源文件

请将 `Fire/Source` 文件夹中所有内容复制到你的项目中。

## 贡献

欢迎任何人提交代码和问题。

## 协议

Fire 是一个开源软体，遵循 `MIT` 协议。

## 使用

要使用 Fire 发送请求，你只需要三个步骤。

首先，构建一个 Fire 实例:

```swift
let f = Fire.build(HTTPMethod: .GET, url: "https://yourdomain.com/get?l=zh")
```

然后，进行一些配置:

```swift
f.setParams(["key": "value"])
f.setFiles([file])
f.setHTTPHeaders(["Accept": "application/json"])
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

最后，发起请求:

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

如果你需要取消请求:

```swift
f.cancel {
   print("Canceled")
}
```

## 示例

```swift
//
//  ViewController.swift
//  Fire-Demo
//
//  Created by Meniny on 2016-04-19.
//  Copyright © 2016 Meniny. All rights reserved.
//

import UIKit
import Fire

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
