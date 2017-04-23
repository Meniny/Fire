
<p align="center">
  <img src="https://ooo.0o0.ooo/2017/04/22/58fac03652695.png" alt="Fire">
  <br/><a href="https://cocoapods.org/pods/Fire">
  <img alt="Version" src="https://img.shields.io/badge/version-2.4.1-brightgreen.svg">
  <img alt="Author" src="https://img.shields.io/badge/author-Meniny-blue.svg">
  <img alt="Build Passing" src="https://img.shields.io/badge/build-passing-brightgreen.svg">
  <img alt="Swift" src="https://img.shields.io/badge/swift-3.0%2B-orange.svg">
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

* [Introduction in English](#Introduction)
* [中文介绍](#中文介绍)

# Introduction

## What's this?

Fire is a delightful HTTP/HTTPS networking framework for iOS/macOS/watchOS/tvOS platform written in Swift and inspired by [Python-Requests: HTTP for Humans](http://docs.python-requests.org/en/master/).

Fire was written for humans to read, and incidentally, for machines to execute :)

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
* macOS 10.10+
* watchOS 2.0+
* tvOS 9.0+
* Xcode 8 with Swift 3

## Dependency

* [Jsonify](https://github.com/Meniny/Jsonify-in-Swift)

## Installation

#### CocoaPods

```ruby
pod 'Fire'
```

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
f.setHTTPBody(raw: json.rawValue)
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

# 中文介绍

## 这是什么?

Fire 一个使用 Swift 书写的轻量级 iOS/macOS/watchOS/tvOS 平台 HTTP/HTTPS 网络框架，深受 [Python-Requests: HTTP for Humans](http://docs.python-requests.org/en/master/) 启发。

Fire 为了更好的可读性而生，碰巧还可以运行 :)

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
* macOS 10.10+
* watchOS 2.0+
* tvOS 9.0+
* Xcode 8 及 Swift 3

## 依赖

* [Jsonify](https://github.com/Meniny/Jsonify-in-Swift)

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
f.setHTTPBody(raw: json.rawValue)
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
