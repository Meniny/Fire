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

// MARK: - Operators

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

/// Fire is a delightful HTTP/HTTPS networking framework for Apple platforms under MIT license.
///
/// It's pretty simple to use:
///
///     Fire.build(...).fire { (json, _) in
///         // ...
///     }
///
/// See [https://github.com/Meniny/Fire-in-Swift/](https://github.com/Meniny/Fire-in-Swift/) for more detail.
///
open class Fire: NSObject, URLSessionDelegate {
    
    public struct Configuration {
        #if DEBUG
            /// if set to true, Fire will log all information in a NSURLSession lifecycle
            public static var DEBUG = true
        #else
            /// if set to true, Fire will log all information in a NSURLSession lifecycle
            public static var DEBUG = false
        #endif
        public static var baseURL: String? = nil
    }
    
    open override var description: String {
        let pa = self.parameters ?? [:]
        let ba = self.basicAuth ?? ("", "")
        return "<[Fire] [\(self.method.rawValue)] \(self.url) \nparameters: \(pa)\nbasic auth: \(ba)\ncer data: \(self.localCertDataArray)>"
    }
    
    private var debugBody: String = ""
    private var expectedResponseType = Fire.ResponseType.data
    private let boundary = "FireUGl0YXlh"
    private let errorDomain = "cn.meniny.Fire"
    
    open var ignoreBaseURL: Bool
    
    open var dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously
    
    open var HTTPBodyRaw = ""
    open var HTTPBodyRawIsJSON = false
    
    open let method: Fire.HTTPMethod
    open var parameters: Fire.Params?
    open var uploadFiles: [Fire.File]?
    
    open var callback: Fire.DataResponseCallback?
    open var errorCallback: Fire.ErrorCallback?
    open var cancelCallback: Fire.VoidCallback?
    open var progressCallback: Fire.ProgressCallback?
    
    open var session: URLSession?
    open let url: String
    open var request: URLRequest?
    open var task: URLSessionTask?
    open var basicAuth: Fire.BasicAuth?
    
    open var localCertDataArray: [Data] = []
    open var SSLValidateErrorCallBack: Fire.VoidCallback?
    
    open var extraHTTPHeaders: [(key: String, value: String)] = []
    
    // User-Agent Header; see http://tools.ietf.org/html/rfc7231#section-5.5.3
    open let userAgent: String = {
        if let info = Bundle.main.infoDictionary {
            let executable: Any = info[kCFBundleExecutableKey as String] ?? "Unknown"
            let bundle: Any = info[kCFBundleIdentifierKey as String] ?? "Unknown"
            let version: Any = info[kCFBundleVersionKey as String] ?? "Unknown"
            // could not tested
            let os = ProcessInfo.processInfo.operatingSystemVersionString
            
            var mutableUserAgent = NSMutableString(string: "\(executable)/\(bundle) (\(version); OS \(os))") as CFMutableString
            let transform = NSString(string: "Any-Latin; Latin-ASCII; [:^ASCII:] Remove") as CFString
            if CFStringTransform(mutableUserAgent, nil, transform, false) {
                return mutableUserAgent as NSString as String
            }
        }
        
        // could not tested
        return "Fire"
    }()
    
    open var customUserAgent: String? = nil
    
    // MARK: - ///////////////////////////// init /////////////////////////////
    
    /**
     the only init method to fire a HTTP / HTTPS request
     
     - parameter method:     the HTTP method you want
     - parameter url:        the url you want
     - parameter timeout:    time out setting
     
     - returns: a Fire object
     */
    public init(url: String, prependBaseURL: Bool = true, method: Fire.HTTPMethod, params: Fire.Params? = nil, timeout: TimeInterval = Fire.DefaultTimeout, dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously) {
        self.ignoreBaseURL = !prependBaseURL
        self.parameters = params
        self.url = Fire.Helper.escape(Fire.Helper.appendURL(url, to: prependBaseURL ? Fire.Configuration.baseURL : nil))
        self.method = method
        self.dispatch = dispatch
        if let u = URL(string: url) {
            self.request = URLRequest(url: u)
        }
        
        super.init()
        
        // setup a session with delegate to self
        let sessionConfiguration = Foundation.URLSession.shared.configuration
        sessionConfiguration.timeoutIntervalForRequest = (timeout <= 0 ? Fire.DefaultTimeout : timeout)
        self.session = Foundation.URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: Foundation.URLSession.shared.delegateQueue)
    }
    
    /**
     the only init method to fire a HTTP / HTTPS request
     
     - parameter method:     the HTTP method you want
     - parameter url:        the url you want
     - parameter timeout:    time out setting
     
     - returns: a Fire object
     */
    public convenience init(HTTPMethod method: HTTPMethod, url: String, prependBaseURL: Bool = true, params: Fire.Params? = nil, timeout: TimeInterval, dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously) {
        self.init(url: url, prependBaseURL: prependBaseURL, method: method, timeout: timeout, dispatch: dispatch)
        self.parameters = params
    }

    // MARK: - ///////////////////////////// build & request & quick usage /////////////////////////////
    
    /**
     the only init method to fire a HTTP / HTTPS request
     
     - parameter method:     the HTTP method you want
     - parameter url:        the url you want
     - parameter timeout:    time out setting
     
     - returns: a Fire object
     */
    @discardableResult open static func build(
        HTTPMethod method: HTTPMethod,
        url: String,
        prependBaseURL: Bool = true,
        params: Fire.Params? = nil,
        timeout: TimeInterval = Fire.DefaultTimeout,
        dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously) -> Fire {
        
        return Fire(HTTPMethod: method, url: url, prependBaseURL: prependBaseURL, params: params, timeout: timeout, dispatch: dispatch)
    }
    
    @discardableResult open static func build(
        api: Fire.API,
        params: Fire.Params? = nil,
        timeout: TimeInterval = Fire.DefaultTimeout,
        dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously) -> Fire {
        
        return Fire.build(HTTPMethod: api.method, url: api.stringValue, prependBaseURL: !api.ignoreBaseURL, timeout: timeout, dispatch: dispatch).setParams(params).addParams(api.defaultParameters ?? [:])
    }
    
    @discardableResult open static func build(
        fileURL: URL,
        name: String,
        mimeType: String,
        toURL: String,
        prependBaseURL: Bool = true,
        params: Fire.Params? = nil,
        timeout: TimeInterval = Fire.DefaultTimeout,
        dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously) -> Fire {
        
        let file = Fire.File(name: name, url: fileURL, mimeType: mimeType)
        
        return Fire.build(HTTPMethod: .POST, url: toURL, prependBaseURL: prependBaseURL, dispatch: dispatch).setParams(params).setFiles([file])
    }
    
    @discardableResult open static func build(
        data: Data,
        name: String,
        ext: String,
        mimeType: String,
        toURL: String,
        prependBaseURL: Bool = true,
        params: Fire.Params? = nil,
        timeout: TimeInterval = Fire.DefaultTimeout,
        dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously) -> Fire {
        
        let file = Fire.File(name: name, data: data, ext: ext, mimeType: mimeType)
        
        return Fire.build(HTTPMethod: .POST, url: toURL, prependBaseURL: prependBaseURL, dispatch: dispatch).setParams(params).setFiles([file])
    }
    
    @discardableResult open static func build(
        files: [Fire.File],
        toURL: String,
        prependBaseURL: Bool = true,
        params: Fire.Params? = nil,
        timeout: TimeInterval = Fire.DefaultTimeout,
        dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously) -> Fire {
        
        return Fire.build(HTTPMethod: .POST, url: toURL, prependBaseURL: prependBaseURL, dispatch: dispatch).setParams(params).setFiles(files)
    }
    
    // MARK: - Request
    
    @discardableResult open static func request(
        HTTPMethod method: HTTPMethod,
        url: String,
        prependBaseURL: Bool = true,
        params: Fire.Params? = nil,
        timeout: TimeInterval = Fire.DefaultTimeout,
        dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously,
        callback: Fire.JOSNResponseCallback?,
        onError: Fire.ErrorCallback?) -> Fire {
        
        return Fire.build(HTTPMethod: method, url: url, prependBaseURL: prependBaseURL, params: params, timeout: timeout, dispatch: dispatch).onError(onError).fireForJSON(callback)
    }
    
    @discardableResult open static func request(
        api: Fire.API,
        params: Fire.Params? = nil,
        timeout: TimeInterval = Fire.DefaultTimeout,
        dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously,
        callback: Fire.JOSNResponseCallback?,
        onError: Fire.ErrorCallback?) -> Fire {
        
        return Fire.build(
            HTTPMethod: api.method,
            url: api.stringValue,
            prependBaseURL: !api.ignoreBaseURL,
            params: params,
            timeout: timeout,
            dispatch: dispatch).addParams(api.defaultParameters ?? [:]).onError(onError).fireForJSON(callback)
    }
    
    @discardableResult open static func sync(
        HTTPMethod
        method: HTTPMethod,
        url: String,
        prependBaseURL: Bool = true,
        params: Fire.Params? = nil,
        timeout: TimeInterval = Fire.DefaultTimeout,
        callback: Fire.JOSNResponseCallback?,
        onError: Fire.ErrorCallback?) -> Fire {
        
        return Fire.request(HTTPMethod: method, url: url, prependBaseURL: prependBaseURL, params: params, timeout: timeout, dispatch: Fire.Dispatch.synchronously, callback: callback, onError: onError)
    }
    
    @discardableResult open static func async(
        HTTPMethod method: HTTPMethod,
        url: String,
        prependBaseURL: Bool = true,
        params: Fire.Params? = nil,
        timeout: TimeInterval = Fire.DefaultTimeout,
        callback: Fire.JOSNResponseCallback?,
        onError: Fire.ErrorCallback?) -> Fire {
        
        return Fire.request(HTTPMethod: method, url: url, prependBaseURL: prependBaseURL, params: params, timeout: timeout, dispatch: Fire.Dispatch.asynchronously, callback: callback, onError: onError)
    }
    
    // MARK: - UPLOAD
    @discardableResult open static func upload(
        fileURL: URL,
        name: String,
        mimeType: String,
        toURL: String,
        prependBaseURL: Bool = true,
        params: Fire.Params? = nil,
        timeout: TimeInterval = Fire.DefaultTimeout,
        dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously,
        progress: Fire.ProgressCallback?,
        callback: Fire.JOSNResponseCallback?,
        onError: Fire.ErrorCallback?) -> Fire {
        
        let file = Fire.File(name: name, url: fileURL, mimeType: mimeType)
        
        return Fire.build(HTTPMethod: .POST, url: toURL, prependBaseURL: prependBaseURL, dispatch: dispatch)
            .setParams(params)
            .handleProgress(progress)
            .setFiles([file])
            .onError(onError)
            .fireForJSON(callback)
    }
    
    @discardableResult open static func upload(
        data: Data,
        name: String,
        ext: String,
        mimeType: String,
        toURL: String,
        prependBaseURL: Bool = true,
        params: Fire.Params? = nil,
        timeout: TimeInterval = Fire.DefaultTimeout,
        dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously,
        progress: Fire.ProgressCallback?,
        callback: Fire.JOSNResponseCallback?,
        onError: Fire.ErrorCallback?) -> Fire {
        
        let file = Fire.File(name: name, data: data, ext: ext, mimeType: mimeType)
        
        return Fire.build(HTTPMethod: .POST, url: toURL, prependBaseURL: prependBaseURL, dispatch: dispatch)
            .setParams(params)
            .setFiles([file])
            .handleProgress(progress)
            .onError(onError)
            .fireForJSON(callback)
    }
    
    @discardableResult open static func upload(
        files: [Fire.File],
        toURL: String,
        prependBaseURL: Bool = true,
        params: Fire.Params? = nil,
        timeout: TimeInterval = Fire.DefaultTimeout,
        dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously,
        progress: Fire.ProgressCallback?,
        callback: Fire.JOSNResponseCallback?,
        onError: Fire.ErrorCallback?) -> Fire {
        
        return Fire.build(HTTPMethod: .POST, url: toURL, prependBaseURL: prependBaseURL, dispatch: dispatch)
            .setParams(params)
            .setFiles(files)
            .onError(onError)
            .fireForJSON(callback)
    }
    
    // MARK: - GET POST PUT DELETE
    @discardableResult open static func get(
        _ url: String,
        prependBaseURL: Bool = true,
        params: Fire.Params? = nil,
        timeout: TimeInterval = Fire.DefaultTimeout,
        dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously,
        callback: Fire.JOSNResponseCallback?,
        onError: Fire.ErrorCallback?) -> Fire {
        
        return Fire.build(
            HTTPMethod: .GET,
            url: url,
            prependBaseURL: prependBaseURL,
            params: params,
            timeout: timeout,
            dispatch: dispatch).onError(onError).fire(callback: callback)
    }
    
    @discardableResult open static func post(
        _ url: String,
        prependBaseURL: Bool = true,
        params: Fire.Params? = nil,
        timeout: TimeInterval = Fire.DefaultTimeout,
        dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously,
        callback: Fire.JOSNResponseCallback?,
        onError: Fire.ErrorCallback?) -> Fire {
        
        return Fire.build(
            HTTPMethod: .POST,
            url: url,
            prependBaseURL: prependBaseURL,
            params: params,
            timeout: timeout,
            dispatch: dispatch).onError(onError).fireForJSON(callback)
    }
    
    @discardableResult open static func put(
        _ url: String,
        prependBaseURL: Bool = true,
        params: Fire.Params? = nil,
        timeout: TimeInterval = Fire.DefaultTimeout,
        dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously,
        callback: Fire.JOSNResponseCallback?,
        onError: Fire.ErrorCallback?) -> Fire {
        
        return Fire.build(
            HTTPMethod: .PUT,
            url: url,
            prependBaseURL: prependBaseURL,
            params: params,
            timeout: timeout,
            dispatch: dispatch).onError(onError).fireForJSON(callback)
    }
    
    @discardableResult open static func delete(
        _ url: String,
        prependBaseURL: Bool = true,
        params: Fire.Params? = nil,
        timeout: TimeInterval = Fire.DefaultTimeout,
        dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously,
        callback: Fire.JOSNResponseCallback?,
        onError: Fire.ErrorCallback?) -> Fire {
        
        return Fire.build(
            HTTPMethod: .DELETE,
            url: url,
            prependBaseURL: prependBaseURL,
            params: params,
            timeout: timeout,
            dispatch: dispatch).onError(onError).fireForJSON(callback)
    }

    // MARK: - ///////////////////////////// setting & adding /////////////////////////////
    
    @discardableResult open func setSSLPinning(localCertData dataArray: [Data], SSLValidateErrorCallBack: Fire.VoidCallback? = nil) -> Fire {
        self.localCertDataArray = dataArray
        self.SSLValidateErrorCallBack = SSLValidateErrorCallBack
        return self
    }
    
    @discardableResult open func addParam(_ key: String, value: Any) -> Fire {
        if self.parameters == nil {
            self.parameters = [:]
        }
        self.parameters![key] = value
        return self
    }
    
    @discardableResult open func addParams(_ params: Fire.Params?) -> Fire {
        if let p = params {
            if self.parameters == nil {
                self.parameters = [:]
            }
            
            for (key, value) in p {
                self.parameters![key] = value
            }
        }
        return self
    }
    
    @discardableResult open func setParams(_ params: Fire.Params?) -> Fire {
        self.parameters = params
        return self
    }
    
    @discardableResult open func addFile(_ file: Fire.File?) -> Fire {
        if let f = file {
            if self.uploadFiles == nil {
                self.uploadFiles = []
            }
            self.uploadFiles!.append(f)
        }
        return self
    }
    
    @discardableResult open func addFiles(_ files: [Fire.File]?) -> Fire {
        if let fs = files {
            if self.uploadFiles == nil {
                self.uploadFiles = []
            }
            self.uploadFiles! += fs
        }
        return self
    }
    
    @discardableResult open func setFiles(_ files: [Fire.File]?) -> Fire {
        self.uploadFiles = files
        return self
    }
    
    @discardableResult open func onError(_ errorCallback: Fire.ErrorCallback?) -> Fire {
        self.errorCallback = errorCallback
        return self
    }
    
    /**
     add a custom HTTP header to current hedaers
     
     - parameter key:   HTTP header key
     - parameter value: HTTP header value
     
     - returns: self (Fire object)
     */
    @discardableResult open func addHTTPHeader(_ value: String, forKey key: String) -> Fire {
        self.extraHTTPHeaders.append((key, value))
        return self
    }
    
    /**
     add custom HTTP headers to current hedaers
     
     - parameter headers: HTTP header [key: value]
     
     - returns: self (Fire object)
     */
    @discardableResult open func addHTTPHeaders(_ headers: Fire.HeaderFields?) -> Fire {
        if let hs = headers {
            for (key, value) in hs {
                self.extraHTTPHeaders.append((key, value))
            }
        }
        return self
    }
    
    /**
     set custom HTTP headers to replace current headers
     
     - parameter headers: HTTP header [key: value]
     
     - returns: self (Fire object)
     */
    @discardableResult open func setHTTPHeaders(_ headers: Fire.HeaderFields?) -> Fire {
        self.cleanHTTPHeaders()
        if let head = headers {
            return self.addHTTPHeaders(head)
        }
        return self
    }
    
    open func cleanHTTPHeaders() {
        self.extraHTTPHeaders.removeAll()
    }
    
    @discardableResult open func setHTTPBody(raw: String, isJSON: Bool = false) -> Fire {
        self.HTTPBodyRaw = raw
        self.HTTPBodyRawIsJSON = isJSON
        return self
    }
    
    /// Progress callback of upload/download task
    ///
    /// - Parameter handler: callback
    /// - Returns: self (Fire object)
    @discardableResult open func handleProgress(_ handler: Fire.ProgressCallback?) -> Fire {
        self.progressCallback = handler
        return self
    }
    
    @discardableResult open func setBasicAuth(_ auth: Fire.BasicAuth) -> Fire {
        self.basicAuth = auth
        return self
    }
    
    @discardableResult open func setUserAgent(_ agent: Fire.UserAgent) -> Fire {
        self.customUserAgent = agent
        return self
    }
    
    // MARK: - ///////////////////////////// fire in hole /////////////////////////////
    
    /**
     async response the http body in NSData type
     
     - parameter callback: callback Closure
     - parameter response: void
     */
    @discardableResult open func fireForData(_ callback: Fire.DataResponseCallback?) -> Fire {
        self.callback = callback
        self.buildRequest()
        self.buildHeader()
        self.buildBody()
        self.fireTask()
        return self
    }
    
    /**
     async response the http body in String type
     
     - parameter callback: callback Closure
     - parameter response: void
     */
    @discardableResult open func fireForString(_ callback: Fire.StringResponseCallback?) -> Fire {
        return self.fireForData { [weak self] (data, response) -> Void in
            self?.expectedResponseType = .string
            var string = ""
            if let d = data,
                let s = NSString(data: d, encoding: String.Encoding.utf8.rawValue) as String? {
                string = s
            }
            callback?(string, response)
            if Fire.Configuration.DEBUG && self?.expectedResponseType == .string {
                let info = self?.printableResponseDebugInfo(of: response, appending: string)
                print(info!)
            }
        }
    }
    
    /**
     async response the http body in JSON type use Jsonify
     
     - parameter callback: callback Closure
     - parameter response: void
     */
    @discardableResult open func fireForJSON(_ callback: Fire.JOSNResponseCallback?) -> Fire {
        return self.fireForString { [weak self] (string, response) in
            self?.expectedResponseType = .JSON
            var json = Jsonify()
            if let s = string {
                json = Jsonify(string: s)
            }
            callback?(json, response)
            if Fire.Configuration.DEBUG && self?.expectedResponseType == .JSON {
                let info = self?.printableResponseDebugInfo(of: response, appending: json.rawValue)
                print(info!)
            }
        }
    }
    
    /**
     async response the http body in JSON type use Jsonify
     
     - parameter callback: callback Closure
     - parameter response: void
     */
    @discardableResult open func fire(forType rt: Fire.ResponseType, callback: Fire.GenericResponseCallback?) -> Fire {
        if let cb = callback {
            switch rt {
            case .JSON:
                return self.fireForJSON { (json, resp) in
                    cb(json, resp, rt)
                }
            case .data:
                return self.fireForData { (data, resp) in
                    cb(data, resp, rt)
                }
            default:
                return self.fireForString { (str, resp) in
                    cb(str, resp, rt)
                }
            }
        } else {
            return self.fireForJSON(nil)
        }
    }
    
    /**
     async response the http body in JSON type use Jsonify
     
     - parameter callback: callback Closure
     - parameter response: void
     */
    @discardableResult open func fire(callback: Fire.JOSNResponseCallback?) -> Fire {
        return self.fireForJSON(callback)
    }
    
    /**
     cancel the request.
     
     - parameter callback: callback Closure
     */
    open func cancel(_ callback: Fire.VoidCallback?) {
        self.cancelCallback = callback
        self.task?.cancel()
        if Fire.Configuration.DEBUG {
            if let u = self.request?.url {
                print("[Fire] Request of \"\(u)\" Cancelled")
            } else {
                if let r = self.request {
                    print("[Fire] Request Cancelled:\n\(r)")
                } else {
                    print("[Fire] Request Cancelled.")
                }
            }
        }
    }
    
    // MARK: - /////////////////////////////
    
    fileprivate func buildRequest() {
        if self.method == .GET && self.parameters?.count > 0 {
            self.request = URLRequest(url: URL(string: url + "?" + Fire.Helper.buildParams(self.parameters!))!)
        }
        self.request?.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        self.request?.httpMethod = self.method.rawValue
    }
    
    fileprivate func buildHeader() {
        // multipart Content-Type; see http://www.rfc-editor.org/rfc/rfc2046.txt
        if self.parameters?.count > 0 {
            let f = ("Content-Type", "application/x-www-form-urlencoded")
            self.request?.setValue(f.1, forHTTPHeaderField: f.0)
        }
        if self.uploadFiles?.count > 0 && self.method != .GET {
            let f = ("Content-Type", "multipart/form-data; boundary=" + self.boundary)
            self.request?.setValue(f.1, forHTTPHeaderField: f.0)
        }
        if self.HTTPBodyRaw != "" {
            let f = ("Content-Type", self.HTTPBodyRawIsJSON ? "application/json" : "text/plain;charset=UTF-8")
            self.request?.setValue(f.0, forHTTPHeaderField: f.1)
        }
        let agentKey = "User-Agent"
        if let agent = self.customUserAgent {
            self.request?.addValue(agent, forHTTPHeaderField: agentKey)
        } else {
            self.request?.addValue(self.userAgent, forHTTPHeaderField: agentKey)
        }
        if let auth = self.basicAuth {
            let authString = "Basic " + (auth.0 + ":" + auth.1).base64!
            self.request?.addValue(authString, forHTTPHeaderField: "Authorization")
        }
        for i in self.extraHTTPHeaders {
            self.request?.setValue(i.1, forHTTPHeaderField: i.0)
        }
    }
    
    fileprivate func buildBody() {
        let data = NSMutableData()
        if !self.HTTPBodyRaw.isEmpty {
            let d1 = self.HTTPBodyRaw
            data.append(d1.data as Data)
            if Fire.Configuration.DEBUG {
                self.debugBody.append(d1)
            }
        } else if self.uploadFiles?.count > 0 {
            if self.method == .GET {
                let sep = "\n------------------------\n"
                let m = "The remote server may not accept GET method with HTTP body. But Fire will send it anyway.\nIt looks like iOS 9 SDK has prevented sending http body in GET method."
                print("\n" + sep + m + sep + "\n")
            } else {
                if let ps = self.parameters {
                    for (key, value) in ps {
                        let d1 = "--\(self.boundary)\r\n"
                        let d2 = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
                        let d3 = "\(value)\r\n"
                        data.append(d1.data as Data)
                        data.append(d2.data as Data)
                        data.append(d3.data as Data)
                        if Fire.Configuration.DEBUG {
                            self.debugBody.append(d1 + d2 + d3)
                        }
                    }
                }
                if let fs = self.uploadFiles {
                    for file in fs {
                        let d1 = "--\(self.boundary)\r\n"
                        let d2 = "Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.nameWithExt)\"\r\n"
                        data.append(d1.data as Data)
                        data.append(d2.data as Data)
                        let d3 = "Content-Type: \(file.mimeType)\r\n\r\n"
                        data.append(d3.data as Data)
                        if Fire.Configuration.DEBUG {
                            self.debugBody.append(d1 + d2 + d3)
                        }
                        if let fileurl = file.url {
                            if let a = try? Data(contentsOf: fileurl as URL) {
                                let d4 = "Data(" + fileurl.absoluteString + ")"
                                data.append(a)
                                let d5 = "\r\n"
                                data.append(d5.data as Data)
                                if Fire.Configuration.DEBUG {
                                    self.debugBody.append(d4 + d5)
                                }
                            }
                        } else if let filedata = file.data {
                            let d4 = "Data(file.data)"
                            data.append(filedata)
                            let d5 = "\r\n"
                            data.append(d5.data as Data)
                            if Fire.Configuration.DEBUG {
                                self.debugBody.append(d4 + d5)
                            }
                        }
                    }
                }
                let d6 = "--\(self.boundary)--\r\n"
                data.append(d6.data as Data)
                if Fire.Configuration.DEBUG {
                    self.debugBody.append(d6)
                }
            }
        } else if self.parameters?.count > 0 && self.method != .GET {
            let d7 = Fire.Helper.buildParams(self.parameters!)
            data.append(d7.data)
            if Fire.Configuration.DEBUG {
                self.debugBody.append(d7)
            }
        } else {
            if Fire.Configuration.DEBUG {
                let d8 = String(describing: data as Data)
                self.debugBody.append(d8.isEmpty ? "Data<\(data.length) Bytes>" : d8)
            }
        }
        self.request?.httpBody = data as Data
        self.request?.setValue("\(data.length)", forHTTPHeaderField: "Content-Length")
    }
    
    fileprivate func printReuestDebugInfo() {
        if Fire.Configuration.DEBUG {
            let sep = "-----------------"
            var output: String = sep + "\n"
            output.append("[Fire] URL: " + self.url)
            if self.method == .GET {
                if let p = self.parameters {
                    output.append("?" + Fire.Helper.buildParams(p))
                }
            }
            output.append("\n")
            output.append("[Fire] HTTP Method: " + self.method.rawValue + "\n")
            output.append("[Fire] HTTP Dispatch: " + self.dispatch.rawValue + "\n")
            if let p = self.parameters {
                output.append("[Fire] Parameters:\n")
                if let plain = p.pretty.unicodeCharactersDecodedString {
                    output.append(plain + "\n")
                } else {
                    output.append(p.pretty + "\n")
                }
            }
            if let a = self.request?.allHTTPHeaderFields {
                output.append("[Fire] Request HEADERS:\n" + a.pretty + "\n")
            }
            let s = "[Fire] Request Body:\n"
            output.append(s + self.debugBody + "\n")
            print(output + sep)
        }
    }
    
    fileprivate func printableResponseDebugInfo(of response: URLResponse?, appending: String) -> String {
        let sep = "-----------------"
        var output = "[Fire] Response Of: "
        if let a = response {
            output.append("\(a.url!)")
            if a is HTTPURLResponse {
                let ah = a as! HTTPURLResponse
                output.append("\n[Fire] Status Code: \(ah.statusCode)\n[Fire] Headers:\n\(ah.allHeaderFields.pretty)")
            }
        }
        output.append("\n[Fire]: Response:\n" + appending)
        return sep + "\n" + output + "\n" + sep
    }
    
    public typealias URLSesstionDataCompletionHandler = ((Data?, URLResponse?, Error?) -> Swift.Void)
    public typealias URLSesstionURLCompletionHandler = ((URL?, URLResponse?, Error?) -> Swift.Void)
    
    fileprivate func fireTask() {
        
        self.printReuestDebugInfo()
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataCompletionHandler: URLSesstionDataCompletionHandler = { [weak self] (data, response, error) -> Void in
            
            semaphore.signal()
            
            if let error = error as NSError? {
                if error.code == -999 {
                    DispatchQueue.main.async {
                        self?.cancelCallback?()
                    }
                } else {
                    let e = NSError(domain: self?.errorDomain ?? "Fire", code: error.code, userInfo: error.userInfo)
                    print("[Fire] Error:\n", e.localizedDescription)
                    DispatchQueue.main.async {
                        self?.errorCallback?(e)
                        self?.session?.finishTasksAndInvalidate()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.callback?(data, response as? HTTPURLResponse)
                    if Fire.Configuration.DEBUG && self?.expectedResponseType == .data {
                        let ds: String
                        if let d = data {
                            ds = String(describing: d )
                        } else {
                            ds = "Data<nil>"
                        }
                        if let s = self?.printableResponseDebugInfo(of: response, appending: ds) {
                            print(s)
                        }
                    }
                    self?.session?.finishTasksAndInvalidate()
                }
            }
        }
        if let r = self.request {
            self.task = self.session?.dataTask(with: r, completionHandler: dataCompletionHandler)
            self.task?.resume()
            
            if self.dispatch == Fire.Dispatch.synchronously {
                semaphore.wait()
            }
        } else {
            if Fire.Configuration.DEBUG {
                print("[Fire] ERROR: Failed to fire task, nil request.")
            }
        }
    }
}

extension Fire: URLSessionTaskDelegate, URLSessionDownloadDelegate {
    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {}
    
    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) * 100
        if self.progressCallback != nil {
            self.progressCallback!(totalBytesWritten, totalBytesExpectedToWrite, progress)
        }
    }
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend) * 100
        if self.progressCallback != nil {
            self.progressCallback!(totalBytesSent, totalBytesExpectedToSend, progress)
        }
    }
}

//private typealias URLSessionDelegate = FireManager

public extension Fire {
    /**
     a delegate method to check whether the remote cartification is the same with given certification.
     
     - parameter session:           NSURLSession
     - parameter challenge:         NSURLAuthenticationChallenge
     - parameter completionHandler: the completionHandler closure
     */
    @objc(URLSession:didReceiveChallenge:completionHandler:) public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if self.localCertDataArray.count == 0 {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, nil)
            return
        }
        if let serverTrust = challenge.protectionSpace.serverTrust,
            let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            let remoteCertificateData: Data = SecCertificateCopyData(certificate) as Data
            
            var checked = false
            
            for localCertificateData in self.localCertDataArray {
                if localCertificateData as Data == remoteCertificateData {
                    if !checked {
                        checked = true
                    }
                }
            }
            
            if checked {
                let credential = URLCredential(trust: serverTrust)
                challenge.sender?.use(credential, for: challenge)
                completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, credential)
            } else {
                challenge.sender?.cancel(challenge)
                completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                DispatchQueue.main.async {
                    self.SSLValidateErrorCallBack?()
                }
                return
            }
        } else {
            // could not test
            print("Fire: Get RemoteCertificateData or LocalCertificateData error!")
        }
    }
}

