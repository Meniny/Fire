
<p align="center">
  <img src="https://ooo.0o0.ooo/2017/07/20/5970669291074.png" alt="Fire">
  <br/><a href="https://cocoapods.org/pods/Fire">
  <img alt="Version" src="https://img.shields.io/badge/version-3.3.5-brightgreen.svg">
  <img alt="Author" src="https://img.shields.io/badge/author-Meniny-blue.svg">
  <img alt="Build Passing" src="https://img.shields.io/badge/build-passing-brightgreen.svg">
  <img alt="Swift" src="https://img.shields.io/badge/swift-4.0%2B-orange.svg">
  <br/>
  <img alt="Platforms" src="https://img.shields.io/badge/platform-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey.svg">
  <img alt="MIT" src="https://img.shields.io/badge/license-MIT-blue.svg">
  <br/>
  <img alt="Cocoapods" src="https://img.shields.io/badge/cocoapods-compatible-brightgreen.svg">
  <img alt="Carthage" src="https://img.shields.io/badge/carthage-working%20on-red.svg">
  <img alt="SPM" src="https://img.shields.io/badge/swift%20package%20manager-working%20on-red.svg">
  </a>
</p>

***

* [English](#Introduction)
* [中文](#中文介绍)
* [⽇本語](#⽇本語)

# Introduction

## What's this?

`Fire` is a delightful HTTP/HTTPS networking framework for iOS/macOS/watchOS/tvOS platform written in Swift and inspired by [Python-Requests: HTTP for Humans](http://docs.python-requests.org/en/master/).

Fire was written for humans to read, and incidentally, for machines to execute :)

## Features

- [x] Chainable Request / Response Methods
- [x] Upload File / Data / MultipartFormData
- [x] HTTP Basic Authorization
- [x] TLS Certificate and Public Key Pinning
- [x] Comprehensive Unit and Integration Test Coverage
- [x] Synchronously/Asynchronously Request
- [x] Timeouts
- [x] Custom Cache Policy
- [x] form (`x-www-form-encoded`)/JSON HTTP body

## Requirements

* iOS 8.0+
* macOS 10.10+
* watchOS 2.0+
* tvOS 9.0+
* Xcode 8 with Swift 3

## Dependency

* [Jsonify](https://github.com/Meniny/Jsonify)

## Installation

#### CocoaPods

```ruby
pod 'Fire'
```

## Contribution

You are welcome to fork and submit pull requests.

## License

`Fire` is open-sourced software, licensed under the `MIT` license.

## Usage

To send a request with `Fire`, you need to do 3 steps.

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
f.setHTTPBody(raw: Data)
let certData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("FireDemo", ofType: "cer")!)!
f.setSSLPinning(localCertData: certData) {
    print("Warning: Under Man-in-the-middle attack!!")
}
f.onError({ (resp, error) -> Void in
    print("Error: Network offline!")
})
```

Finally, fire up:

```swift
f.fire { (json, resp) -> Void in
    print(json["arg"]["key"].stringValue)
}

// or

f.fireForJSON { (json, resp) -> Void in
    print(json["arg"]["key"].stringValue)
}

// or

f.fireForString { (str, resp) -> Void in
    print(str)
}

// or

f.fireForData { (data, resp) -> Void in
    print("Success")
}
```

If you want to cancel it:

```swift
// cancel:
f.onCancel {
  print("Canceled")
}
f.cancel()
// or:
f.cancel {
   print("Canceled")
}
```

Use `Fire.Dispatch` if you want to send requests synchronously:

```swift
let f = Fire.build(HTTPMethod: .GET, url: api.stringValue, timeout: timeout, dispatch: .synchronously)
```

`Fire.API`:

```swift
open class func FireAPI1() {
    Fire.API.baseURL = FireDemo.BASEURL
    let api = Fire.API(appending: "get.php", HTTPMethod: .GET, successCode: .success)
    Fire.request(api: api, params: [:], timeout: 0, callback: { (json, resp) in
        if let status = resp?.statusCode {
            if status == api.successCode.rawValue {
                // ...
            }
        }
    }) { (error) in
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
    }) { (error) in
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
    }) { (error) in
        print(error.localizedDescription)
    }
}
```

# 中文介绍

## 这是什么?

`Fire` 一个使用 Swift 书写的轻量级 iOS/macOS/watchOS/tvOS 平台 HTTP/HTTPS 网络框架，深受 [Python-Requests: HTTP for Humans](http://docs.python-requests.org/en/master/) 启发。

Fire 为了更好的可读性而生，碰巧还可以运行 :)

## 特性

- [x] 链式调用的请求和响应方法
- [x] 上传文件和数据
- [x] 支持 HTTP Basic 认证
- [x] 支持 SSL Pinning
- [x] 全面的单元和集成测试覆盖
- [x] 同步/异步请求
- [x] 超时
- [x] 自定义缓存策略
- [x] 支持 form (`x-www-form-encoded`)/JSON HTTP 请求体

## 环境

* iOS 8.0+
* macOS 10.10+
* watchOS 2.0+
* tvOS 9.0+
* Xcode 8 及 Swift 3

## 依赖

* [Jsonify](https://github.com/Meniny/Jsonify)

## 安装

#### CocoaPods

```ruby
pod 'Fire'
```

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
f.setHTTPBody(raw: Data)
let certData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("FireDemo", ofType: "cer")!)!
f.setSSLPinning(localCertData: certData) {
    print("Warning: Under Man-in-the-middle attack!!")
}
f.onError({ (resp, error) -> Void in
    print("Error: Network offline!")
})
```

最后，发起请求:

```swift
f.fire { (json, resp) -> Void in
    print(json["arg"]["key"].stringValue)
}

// or

f.fireForJSON { (json, resp) -> Void in
    print(json["arg"]["key"].stringValue)
}

// or

f.fireForString { (str, resp) -> Void in
    print(str)
}

// or

f.fireForData { (data, resp) -> Void in
    print("Success")
}
```

如果你需要取消请求:

```swift
// cancel:
f.onCancel {
  print("Canceled")
}
f.cancel()
// or:
f.cancel {
   print("Canceled")
}
```

如果你想发送同步请求, 请使用 `Fire.Dispatch`:

```swift
let f = Fire.build(HTTPMethod: .GET, url: api.stringValue, timeout: timeout, dispatch: .synchronously)
```

`Fire.API`:

```swift
open class func FireAPI1() {
    Fire.API.baseURL = FireDemo.BASEURL
    let api = Fire.API(appending: "get.php", HTTPMethod: .GET, successCode: .success)
    Fire.request(api: api, params: [:], timeout: 0, callback: { (json, resp) in
        if let status = resp?.statusCode {
            if status == api.successCode.rawValue {
                // ...
            }
        }
    }) { (error) in
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
    }) { (error) in
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
    }) { (error) in
        print(error.localizedDescription)
    }
}
```

# ⽇本語

## Fire とは何か？

`Fire` とは Swift で作られる iOS/macOS/watchOS/tvOSiプラットホーム HTTP/HTTPS の軽量なデータのインタネットフレームワーク(Internet-Framework)、[Python-Requests:HTTP for Humans](http://docs.python-requests.org/en/master/) に深い影響を与えられた。

人を理解やすくなるために、作られました。たまたまにプログラムを実行できる。

## フィーチャー(Features)

- [x] 連鎖されるリクエストとレスポンス のメソッド
- [x] Upload file/data 可能
- [x] HTTP Basic 認証をサポートしている
- [x] SSL Pinning をサポートしている
- [x] 全局と局部的なテスト可能
- [x] 同期通信/非同期通信
- [x] タイムアウト
- [x] URLCachePolicy
- [x] form (`x-www-form-encoded`)/JSON HTTP 制式をサポートしている

## 開発環境/動作環境

* iOS 8.0 以上
* macOS 10.10 以上
* watchOS 2.0 以上
* tvOS 9.0 以上
* Xcode 8 / Swift 3 以上

## インストール

#### CocoaPods

`CocoaPods` でライブラリをインストールします。

Podfile:

```ruby
pod 'Fire'
```

プロジェクトのディレクトリ内で以下を実行 `pod install`

## ライセンス

関連するリポジトリ含め、すべてMITです。詳細は各リポジトリ内のLICENSEをご覧ください。

## 貢献ガイド、サポート情報、ご留意事項

`@渋谷の猫`

(※準備中です)

## 開発/ビルド方法/使用方法

1. `Fire.build`

```swift
let f = Fire.build(HTTPMethod: .GET, url: "https://yourdomain.com/get?l=zh")
```

2. `set...`/`add...`

```swift
f.setParams(["key": "value"])
f.setFiles([file])
f.setHTTPHeaders(["Accept": "application/json"])
f.setBasicAuth("user", password: "pwd!@#")
f.setHTTPBody(raw: Data)
let certData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("FireDemo", ofType: "cer")!)!
f.setSSLPinning(localCertData: certData) {
    print("Warning: Under Man-in-the-middle attack!!")
}
f.onError({ (resp, error) -> Void in
    print("Error: Network offline!")
})
```

3. `fire { (...) in }`

```swift
f.fire { (json, resp) -> Void in
    print(json["arg"]["key"].stringValue)
}

// or

f.fireForJSON { (json, resp) -> Void in
    print(json["arg"]["key"].stringValue)
}

// or

f.fireForString { (str, resp) -> Void in
    print(str)
}

// or

f.fireForData { (data, resp) -> Void in
    print("Success")
}
```

```swift
// cancel:
f.onCancel {
  print("Canceled")
}
f.cancel()
// or:
f.cancel {
   print("Canceled")
}
```

`Fire.Dispatch`:

```swift
let f = Fire.build(HTTPMethod: .GET, url: api.stringValue, timeout: timeout, dispatch: .synchronously)
```

`Fire.API`:

```swift
open class func FireAPI1() {
    Fire.API.baseURL = FireDemo.BASEURL
    let api = Fire.API(appending: "get.php", HTTPMethod: .GET, successCode: .success)
    Fire.request(api: api, params: [:], timeout: 0, callback: { (json, resp) in
        if let status = resp?.statusCode {
            if status == api.successCode.rawValue {
                // ...
            }
        }
    }) { (error) in
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
    }) { (error) in
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
    }) { (error) in
        print(error.localizedDescription)
    }
}
```
