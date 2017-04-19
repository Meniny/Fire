// The MIT License (MIT)

// Copyright (c) 2015 Meniny <meniny@qq.com> https://github.com/Meniny

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//  Fire.swift
//  Fire
//
//  Created by Meniny on 15/5/14.
//

import Foundation

public typealias FireJOSNResponseCallback = ((_ json: FireJSON, _ response: HTTPURLResponse?) -> Void)
public typealias FireDataResponseCallback = ((_ data: Data?, _ response: HTTPURLResponse?) -> Void)
public typealias FireStringResponseCallback = ((_ string: String?, _ response: HTTPURLResponse?) -> Void)

public typealias FireErrorCallback = ((_ error: Error) -> Void)

open class Fire {
    
    /// if set to true, Fire will log all information in a NSURLSession lifecycle
    open static var DEBUG = false
    open static var baseURL: String?
    
    var fireManager: FireManager!

    /**
    the only init method to fire a HTTP / HTTPS request
    
    - parameter method:     the HTTP method you want
    - parameter url:        the url you want
    - parameter timeout:    time out setting
    
    - returns: a Fire object
    */
    open static func build(HTTPMethod method: HTTPMethod, url: String, timeout: Double = FireManager.oneMinute) -> Fire {
        return Fire(HTTPMethod: method, url: url, timeout: timeout)
//        let p = Fire()
//        p.fireManager = FireManager.build(method, url: url, timeout: timeout)
//        return p
    }
    
    /**
     the only init method to fire a HTTP / HTTPS request
     
     - parameter method:     the HTTP method you want
     - parameter url:        the url you want
     - parameter timeout:    time out setting
     
     - returns: a Fire object
     */
    init(HTTPMethod method: HTTPMethod, url: String, timeout: Double) {
        let fullURL = (Fire.baseURL == nil ? url : (Fire.baseURL! + url))
        self.fireManager = FireManager.build(method, url: fullURL, timeout: timeout)
    }


    /**
    add params to self (Fire object)
    
    - parameter params: what params you want to add in the request. Fire will do things right whether methed is GET or POST.
    
    - returns: self (Fire object)
    */
    open func addParams(_ params: [String: Any]) -> Fire {
        self.fireManager.addParams(params)
        return self
    }
    
    /**
     add param to self (Fire object), Fire will do things right whether methed is GET or POST.
     
     - parameter key: key for parameter.
     - parameter key: value for parameter.
     
     - returns: self (Fire object)
     */
    open func addParam(_ key: String, value: Any) -> Fire {
        self.fireManager.addParams([key: value])
        return self
    }
    
    /**
    add files to self (Fire object), POST only
    
    - parameter params: add some files to request
    
    - returns: self (Fire object)
    */
    open func addFiles(_ files: [UploadFile]) -> Fire {
        self.fireManager.addFiles(files)
        return self
    }
    
    /**
    add a SSL pinning to check whether undering the Man-in-the-middle attack
    
    - parameter data:                     data of certification file, .cer format
    - parameter SSLValidateErrorCallBack: error callback closure
    
    - returns: self (Fire object)
    */
    open func addSSLPinning(LocalCertData data: Data, SSLValidateErrorCallBack: (()->Void)? = nil) -> Fire {
        self.fireManager.addSSLPinning(LocalCertData: [data], SSLValidateErrorCallBack: SSLValidateErrorCallBack)
        return self
    }
    
    /**
     add a SSL pinning to check whether undering the Man-in-the-middle attack
     
     - parameter LocalCertDataArray:       data array of certification file, .cer format
     - parameter SSLValidateErrorCallBack: error callback closure
     
     - returns: self (Fire object)
     */
    open func addSSLPinning(LocalCertDataArray dataArray: [Data], SSLValidateErrorCallBack: (()->Void)? = nil) -> Fire {
        self.fireManager.addSSLPinning(LocalCertData: dataArray, SSLValidateErrorCallBack: SSLValidateErrorCallBack)
        return self
    }
    
    /**
    set a custom HTTP header
    
    - parameter key:   HTTP header key
    - parameter value: HTTP header value
    
    - returns: self (Fire object)
    */
    open func setHTTPHeader(Name key: String, Value value: String) -> Fire {
        self.fireManager.setHTTPHeader(Name: key, Value: value)
        return self
    }

    /**
    set HTTP body to what you want. This method will discard any other HTTP body you have built.
    
    - parameter string: HTTP body string you want
    - parameter isJSON: is JSON or not: will set "Content-Type" of HTTP request to "application/json" or "text/plain;charset=UTF-8"
    
    - returns: self (Fire object)
    */
    open func setHTTPBodyRaw(_ string: String, isJSON: Bool = false) -> Fire {
        self.fireManager.sethttpBodyRaw(string, isJSON: isJSON)
        return self
    }
    
    /**
    set username and password of HTTP Basic Auth to the HTTP request header
    
    - parameter username: username
    - parameter password: password
    
    - returns: self (Fire object)
    */
    open func setBasicAuth(_ username: String, password: String) -> Fire {
        self.fireManager.setBasicAuth((username, password))
        return self
    }
    
    /**
    add error callback to self (Fire object).
    this will called only when network error, if we can receive any data from server, responseData() will be fired.
    
    - parameter errorCallback: errorCallback Closure
    
    - returns: self (Fire object)
    */
    open func onNetworkError(_ errorCallback: @escaping FireErrorCallback) -> Fire {
        self.fireManager.addErrorCallback(errorCallback)
        return self
    }
    
    /**
    async response the http body in NSData type
    
    - parameter callback: callback Closure
    - parameter response: void
    */
    open func responseData(_ callback: FireDataResponseCallback?) {
        self.fireManager?.fire(callback)
    }
    
    /**
    async response the http body in String type
    
    - parameter callback: callback Closure
    - parameter response: void
    */
    open func responseString(_ callback: FireStringResponseCallback?) {
        self.responseData { (data, response) -> Void in
            var string = ""
            if let d = data,
                let s = NSString(data: d, encoding: String.Encoding.utf8.rawValue) as String? {
                    string = s
            }
            callback?(string, response)
        }
    }
    
    /**
    async response the http body in JSON type use FireJSON
    
    - parameter callback: callback Closure
    - parameter response: void
    */
    open func responseJSON(_ callback: FireJOSNResponseCallback?) {//((_ json: FireJSON, _ response: HTTPURLResponse?) -> Void)?) {
        self.responseString { (string, response) in
            var json = FireJSON()
            if let s = string {
                json = FireJSON(string: s)
            }
            callback?(json, response)
        }
    }
    
    /**
    cancel the request.
     
     - parameter callback: callback Closure
     */
    open func cancel(_ callback: (() -> Void)?) {
        self.fireManager.cancelCallback = callback
        self.fireManager.task.cancel()
    }
}

// MARK: - Simple
extension Fire {

    open static var FireEmptyErrorCallback: FireErrorCallback = { (error) in }
    
    
    // MARK: Builder
    
    open static func build(api: FireAPI, params: [String: Any], timeout: Double = FireManager.oneMinute) -> Fire {
        return Fire.build(HTTPMethod: api.method, url: api.stringValue, timeout: timeout).addParams(params)
    }
    
    open static func build(HTTPMethod method: HTTPMethod, url: String, params: [String: Any], timeout: Double = FireManager.oneMinute) -> Fire {
        return Fire.build(HTTPMethod: .GET, url: url, timeout: timeout).addParams(params)
    }
    
    open static func build(uploadFile fileURL: URL, name: String, toURL: String, params: [String: Any] = [:], timeout: Double = FireManager.oneMinute) -> Fire {
        let file = UploadFile(name: name, url: fileURL)
        return Fire.build(HTTPMethod: .POST, url: toURL).addParams(params).addFiles([file])
    }
    
    open static func build(uploadData data: Data, name: String, type: String, toURL: String, params: [String: Any] = [:], timeout: Double = FireManager.oneMinute) -> Fire {
        let file = UploadFile(name: name, data: data, type: type)
        return Fire.build(HTTPMethod: .POST, url: toURL).addParams(params).addFiles([file])
    }
    
    open static func build(uploadFiles files: [UploadFile], toURL: String, params: [String: Any] = [:], timeout: Double = FireManager.oneMinute) -> Fire {
        return Fire.build(HTTPMethod: .POST, url: toURL).addParams(params).addFiles(files)
    }
    
    open func setHTTPHeaders(_ headers: [String: String]) -> Fire {
        for (key, value) in headers {
            self.fireManager.setHTTPHeader(Name: key, Value: value)
        }
        return self
    }
    
    // MARK: - Callback
    
    open static func request(HTTPMethod method: HTTPMethod, url: String, params: [String: Any], timeout: Double = FireManager.oneMinute, callback: FireJOSNResponseCallback?, onNetworkError: FireErrorCallback?) {
        Fire.build(HTTPMethod: method, url: url, params: params, timeout: timeout)
            .onNetworkError(onNetworkError == nil ? FireEmptyErrorCallback : onNetworkError!)
            .responseJSON(callback)
    }
    
    open static func requestAPI(_ api: FireAPI, params: [String: Any], timeout: Double = FireManager.oneMinute, callback: FireJOSNResponseCallback?, onNetworkError: FireErrorCallback?) {
        Fire.build(HTTPMethod: api.method, url: api.stringValue, params: params, timeout: timeout)
            .onNetworkError(onNetworkError == nil ? FireEmptyErrorCallback : onNetworkError!)
            .responseJSON(callback)
    }
    
    open static func get(_ url: String, params: [String: Any], timeout: Double = FireManager.oneMinute, callback: FireJOSNResponseCallback?, onNetworkError: FireErrorCallback?) {
        Fire.build(HTTPMethod: .GET, url: url, params: params, timeout: timeout)
            .onNetworkError(onNetworkError == nil ? FireEmptyErrorCallback : onNetworkError!)
            .responseJSON(callback)
    }
    
    open static func post(_ url: String, params: [String: Any], timeout: Double = FireManager.oneMinute, callback: FireJOSNResponseCallback?, onNetworkError: FireErrorCallback?) {
        Fire.build(HTTPMethod: .POST, url: url, params: params, timeout: timeout)
            .onNetworkError(onNetworkError == nil ? FireEmptyErrorCallback : onNetworkError!)
            .responseJSON(callback)
    }
    
    open static func put(_ url: String, params: [String: Any], timeout: Double = FireManager.oneMinute, callback: FireJOSNResponseCallback?, onNetworkError: FireErrorCallback?) {
        Fire.build(HTTPMethod: .PUT, url: url, params: params, timeout: timeout)
            .onNetworkError(onNetworkError == nil ? FireEmptyErrorCallback : onNetworkError!)
            .responseJSON(callback)
    }
    
    open static func delete(_ url: String, params: [String: Any], timeout: Double = FireManager.oneMinute, callback: FireJOSNResponseCallback?, onNetworkError: FireErrorCallback?) {
        Fire.build(HTTPMethod: .DELETE, url: url, params: params, timeout: timeout)
            .onNetworkError(onNetworkError == nil ? FireEmptyErrorCallback : onNetworkError!)
            .responseJSON(callback)
    }
}
