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
import Jsonify

public typealias FireJSON = Jsonify

public typealias FireJOSNResponseCallback = ((_ json: FireJSON, _ response: HTTPURLResponse?) -> Void)
public typealias FireDataResponseCallback = ((_ data: Data?, _ response: HTTPURLResponse?) -> Void)
public typealias FireURLResponseCallback = ((_ url: URL?, _ response: HTTPURLResponse?) -> Void)
public typealias FireStringResponseCallback = ((_ string: String?, _ response: HTTPURLResponse?) -> Void)
public typealias FireVoidCallback = (() -> Void)
public typealias FireErrorCallback = ((_ error: Error) -> Void)
public typealias FireProgressCallback = ((_ completedBytes: Int64, _ totalBytes: Int64, _ progress: Float) -> Void)

open class Fire {
    
    /// if set to true, Fire will log all information in a NSURLSession lifecycle
    open static var DEBUG = false
    open static var baseURL: String?
    
    open var fireManager: FireManager!

    /**
    the only init method to fire a HTTP / HTTPS request
    
    - parameter method:     the HTTP method you want
    - parameter url:        the url you want
    - parameter timeout:    time out setting
    
    - returns: a Fire object
    */
    open static func build(HTTPMethod method: HTTPMethod, url: String, params: [String: Any]? = nil, timeout: Double = FireManager.oneMinute) -> Fire {
        return Fire(HTTPMethod: method, url: url, params: params, timeout: timeout)
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
    public init(HTTPMethod method: HTTPMethod, url: String, params: [String: Any]? = nil, timeout: Double) {
        let fullURL = (Fire.baseURL == nil ? url : (Fire.baseURL! + url))
        self.fireManager = FireManager.build(method, url: fullURL, timeout: timeout)
        self.fireManager.setParams(params)
    }


    /**
    set parameters of self (Fire object)
    
    - parameter params: what parameters you want to add in the request. Fire will do things right whether methed is GET or POST.
    
    - returns: self (Fire object)
    */
    open func setParams(_ params: [String: Any]?) -> Fire {
        self.fireManager.setParams(params)
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
     add parameters to self (Fire object), Fire will do things right whether methed is GET or POST.
     
     - parameter params: what parameters you want to add in the request.
     
     - returns: self (Fire object)
     */
    open func addParams(_ params: [String: Any]) -> Fire {
        self.fireManager.addParams(params)
        return self
    }
    
    /**
     add a file to self (Fire object), POST only
     
     - parameter file: add a file to request
     
     - returns: self (Fire object)
     */
    open func addFile(_ file: FileInfo) -> Fire {
        self.fireManager.addFile(file)
        return self
    }
    
    /**
     add files to self (Fire object), POST only
     
     - parameter files: add some files to request
     
     - returns: self (Fire object)
     */
    open func addFiles(_ files: [FileInfo]) -> Fire {
        self.fireManager.addFiles(files)
        return self
    }
    
    /**
    set files of self (Fire object), POST only
    
    - parameter files: add some files to request
    
    - returns: self (Fire object)
    */
    open func setFiles(_ files: [FileInfo]?) -> Fire {
        self.fireManager.setFiles(files)
        return self
    }
    
    /**
    add a SSL pinning to check whether undering the Man-in-the-middle attack
    
    - parameter data:                     data of certification file, .cer format
    - parameter SSLValidateErrorCallBack: error callback closure
    
    - returns: self (Fire object)
    */
    open func setSSLPinning(localCertData data: Data, SSLValidateErrorCallBack: FireVoidCallback? = nil) -> Fire {
        self.fireManager.setSSLPinning(localCertData: [data], SSLValidateErrorCallBack: SSLValidateErrorCallBack)
        return self
    }
    
    /**
     add a SSL pinning to check whether undering the Man-in-the-middle attack
     
     - parameter LocalCertDataArray:       data array of certification file, .cer format
     - parameter SSLValidateErrorCallBack: error callback closure
     
     - returns: self (Fire object)
     */
    open func setSSLPinning(localCertDataArray dataArray: [Data], SSLValidateErrorCallBack: FireVoidCallback? = nil) -> Fire {
        self.fireManager.setSSLPinning(localCertData: dataArray, SSLValidateErrorCallBack: SSLValidateErrorCallBack)
        return self
    }
    
    /**
    add a custom HTTP header to current hedaers
    
    - parameter value: HTTP header value
    - parameter key:   HTTP header key
    
    - returns: self (Fire object)
    */
    open func addHTTPHeader(_ value: String, forKey key: String) -> Fire {
        self.fireManager.addHTTPHeader(value, forKey: key)
        return self
    }
    
    /**
     add custom HTTP headers to current hedaers
     
     - parameter headers: HTTP header [key: value]
     
     - returns: self (Fire object)
     */
    open func addHTTPHeaders(_ headers: [String: String]) -> Fire {
        self.fireManager.addHTTPHeaders(headers)
        return self
    }
    
    /**
     set custom HTTP headers to replace current headers
     
     - parameter headers: HTTP header [key: value]
     
     - returns: self (Fire object)
     */
    open func setHTTPHeaders(_ headers: [String: String]?) -> Fire {
        self.fireManager.setHTTPHeaders(headers!)
        return self
    }
    
    /**
     clean all the HTTP headers
     
     - returns: self (Fire object)
     */
    open func cleanHTTPHeaders() -> Fire {
        self.fireManager.cleanHTTPHeaders()
        return self
    }

    /**
    set HTTP body to what you want. This method will discard any other HTTP body you have built.
    
    - parameter string: HTTP body string you want
    - parameter isJSON: is JSON or not: will set "Content-Type" of HTTP request to "application/json" or "text/plain;charset=UTF-8"
    
    - returns: self (Fire object)
    */
    open func setHTTPBody(raw: String, isJSON: Bool = false) -> Fire {
        self.fireManager.sethttpBody(raw: raw, isJSON: isJSON)
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
    this will called only when network error, if we can receive any data from server, fireForData() will be fired.
    
    - parameter errorCallback: errorCallback Closure
    
    - returns: self (Fire object)
    */
    open func onError(_ errorCallback: @escaping FireErrorCallback) -> Fire {
        self.fireManager.onError(errorCallback)
        return self
    }
    
    /**
    async response the http body in NSData type
    
    - parameter callback: callback Closure
    - parameter response: void
    */
    open func fireForData(_ callback: FireDataResponseCallback?) {
        self.fireManager?.fire(callback)
    }
    
    /**
    async response the http body in String type
    
    - parameter callback: callback Closure
    - parameter response: void
    */
    open func fireForString(_ callback: FireStringResponseCallback?) {
        self.fireForData { (data, response) -> Void in
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
    open func fireForJSON(_ callback: FireJOSNResponseCallback?) {
        self.fireForString { (string, response) in
            var json = FireJSON()
            if let s = string {
                json = FireJSON(string: s)
            }
            callback?(json, response)
        }
    }
    
    /**
     async response the http body in JSON type use FireJSON
     
     - parameter callback: callback Closure
     - parameter response: void
     */
    open func fire(_ callback: FireJOSNResponseCallback?) {
        self.fireForJSON(callback)
    }
    
    /**
    cancel the request.
     
     - parameter callback: callback Closure
     */
    open func cancel(_ callback: FireVoidCallback?) {
        self.fireManager.cancelCallback = callback
        self.fireManager.task.cancel()
    }
}

// MARK: - Simple Usage
extension Fire {

    open static var FireEmptyErrorCallback: FireErrorCallback = { (error) in }
    
    // MARK: Builder
    
    open static func build(api: FireAPI, params: [String: Any]? = nil, timeout: Double = FireManager.oneMinute) -> Fire {
        return Fire.build(HTTPMethod: api.method, url: api.stringValue, timeout: timeout).setParams(params)
    }
    
    open static func build(fileURL: URL, name: String, mimeType: String, toURL: String, params: [String: Any]? = nil, timeout: Double = FireManager.oneMinute) -> Fire {
        let file = FileInfo(name: name, url: fileURL, mimeType: mimeType)
        return Fire.build(HTTPMethod: .POST, url: toURL).setParams(params).setFiles([file])
    }
    
    open static func build(data: Data, name: String, ext: String, mimeType: String, toURL: String, params: [String: Any]? = nil, timeout: Double = FireManager.oneMinute) -> Fire {
        let file = FileInfo(name: name, data: data, ext: ext, mimeType: mimeType)
        return Fire.build(HTTPMethod: .POST, url: toURL).setParams(params).setFiles([file])
    }
    
    open static func build(files: [FileInfo], toURL: String, params: [String: Any]? = nil, timeout: Double = FireManager.oneMinute) -> Fire {
        return Fire.build(HTTPMethod: .POST, url: toURL).setParams(params).setFiles(files)
    }
    
    // MARK: - Request
    
    open static func request(HTTPMethod method: HTTPMethod, url: String, params: [String: Any]? = nil, timeout: Double = FireManager.oneMinute, callback: FireJOSNResponseCallback?, onError: FireErrorCallback?) {
        Fire.build(HTTPMethod: method, url: url, params: params, timeout: timeout)
            .onError(onError == nil ? FireEmptyErrorCallback : onError!)
            .fire(callback)
    }
    
    open static func request(api: FireAPI, params: [String: Any]? = nil, timeout: Double = FireManager.oneMinute, callback: FireJOSNResponseCallback?, onError: FireErrorCallback?) {
        Fire.build(HTTPMethod: api.method, url: api.stringValue, params: params, timeout: timeout)
            .onError(onError == nil ? FireEmptyErrorCallback : onError!)
            .fire(callback)
    }
    
    // MARK: - UPLOAD
    open static func upload(fileURL: URL, name: String, mimeType: String, toURL: String, params: [String: Any]? = nil, timeout: Double = FireManager.oneMinute, progress: FireProgressCallback?, callback: FireJOSNResponseCallback?, onError: FireErrorCallback?) {
        let file = FileInfo(name: name, url: fileURL, mimeType: mimeType)
        Fire.build(HTTPMethod: .POST, url: toURL)
            .setParams(params)
            .handleProgress(progress)
            .setFiles([file])
            .onError(onError == nil ? FireEmptyErrorCallback : onError!)
            .fire(callback)
    }
    
    open static func upload(data: Data, name: String, ext: String, mimeType: String, toURL: String, params: [String: Any]? = nil, timeout: Double = FireManager.oneMinute, progress: FireProgressCallback?, callback: FireJOSNResponseCallback?, onError: FireErrorCallback?) {
        let file = FileInfo(name: name, data: data, ext: ext, mimeType: mimeType)
        Fire.build(HTTPMethod: .POST, url: toURL)
            .setParams(params)
            .handleProgress(progress)
            .setFiles([file])
            .onError(onError == nil ? FireEmptyErrorCallback : onError!)
            .fire(callback)
    }
    
    open static func upload(files: [FileInfo], toURL: String, params: [String: Any]? = nil, timeout: Double = FireManager.oneMinute, progress: FireProgressCallback?, callback: FireJOSNResponseCallback?, onError: FireErrorCallback?) {
        Fire.build(HTTPMethod: .POST, url: toURL)
            .setParams(params)
            .setFiles(files)
            .onError(onError == nil ? FireEmptyErrorCallback : onError!)
            .fire(callback)
    }
    
    open func handleProgress(_ handler: FireProgressCallback?) -> Fire {
        self.fireManager.progressCallback = handler
        return self
    }
    
    // MARK: - GET POST PUT DELETE
    open static func get(_ url: String, params: [String: Any]? = nil, timeout: Double = FireManager.oneMinute, callback: FireJOSNResponseCallback?, onError: FireErrorCallback?) {
        Fire.build(HTTPMethod: .GET, url: url, params: params, timeout: timeout)
            .onError(onError == nil ? FireEmptyErrorCallback : onError!)
            .fire(callback)
    }
    
    open static func post(_ url: String, params: [String: Any]? = nil, timeout: Double = FireManager.oneMinute, callback: FireJOSNResponseCallback?, onError: FireErrorCallback?) {
        Fire.build(HTTPMethod: .POST, url: url, params: params, timeout: timeout)
            .onError(onError == nil ? FireEmptyErrorCallback : onError!)
            .fire(callback)
    }
    
    open static func put(_ url: String, params: [String: Any]? = nil, timeout: Double = FireManager.oneMinute, callback: FireJOSNResponseCallback?, onError: FireErrorCallback?) {
        Fire.build(HTTPMethod: .PUT, url: url, params: params, timeout: timeout)
            .onError(onError == nil ? FireEmptyErrorCallback : onError!)
            .fire(callback)
    }
    
    open static func delete(_ url: String, params: [String: Any]? = nil, timeout: Double = FireManager.oneMinute, callback: FireJOSNResponseCallback?, onError: FireErrorCallback?) {
        Fire.build(HTTPMethod: .DELETE, url: url, params: params, timeout: timeout)
            .onError(onError == nil ? FireEmptyErrorCallback : onError!)
            .fire(callback)
    }
}
