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
//  FireManager.swift
//  Fire
//
//  Created by Meniny on 15/10/7.
//

import Foundation

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

//public enum FireTaskType {
//    case dataTask, uploadDataTask, uploadFileTask, download
//}

// MARK: - Class

open class FireManager: NSObject, URLSessionDelegate {
    static var oneMinute: Double = 60.0
    
    var debugBody: String = ""
    
//    open var taskType: FireTaskType = .dataTask
    
    let boundary = "FireUGl0YXlh"
    let errorDomain = "cn.meniny.Fire"
    
    var HTTPBodyRaw = ""
    var HTTPBodyRawIsJSON = false
    
    open let method: HTTPMethod!
    open var parameters: [String: Any]?
    open var uploadFiles: [FileInfo]?
    var cancelCallback: FireVoidCallback?
    var errorCallback: FireErrorCallback?
    var callback: FireDataResponseCallback?
    
    open var session: URLSession!
    open let url: String!
    open var request: URLRequest!
    open var task: URLSessionTask!
    open var basicAuth: (String, String)!
    
    open var localCertDataArray: [Data] = []
    var sSLValidateErrorCallBack: FireVoidCallback?
    
    open var extraHTTPHeaders: [(String, String)] = []
    
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

    public init(url: String, method: HTTPMethod!, timeout: Double = FireManager.oneMinute) {
        self.url = url
        self.request = URLRequest(url: URL(string: url)!)
        self.method = method
        
        super.init()
        // setup a session with delegate to self
        let sessionConfiguration = Foundation.URLSession.shared.configuration
        sessionConfiguration.timeoutIntervalForRequest = (timeout <= 0 ? FireManager.oneMinute : timeout)
        self.session = Foundation.URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: Foundation.URLSession.shared.delegateQueue)
    }
    
    open func setSSLPinning(localCertData dataArray: [Data], SSLValidateErrorCallBack: FireVoidCallback? = nil) {
        self.localCertDataArray = dataArray
        self.sSLValidateErrorCallBack = SSLValidateErrorCallBack
    }
    
    open func addParam(_ key: String, value: Any) {
        if self.parameters == nil {
            self.parameters = [:]
        }
        self.parameters![key] = value
    }
    
    open func addParams(_ params: [String: Any]) {
        if self.parameters != nil {
            self.parameters = [:]
        }
        for (key, value) in params {
            self.parameters![key] = value
        }
    }
    
    open func setParams(_ params: [String: Any]?) {
        self.parameters = params
    }
    
    open func addFile(_ file: FileInfo) {
        if self.uploadFiles == nil {
            self.uploadFiles = []
        }
        self.uploadFiles!.append(file)
    }
    
    open func addFiles(_ files: [FileInfo]) {
        if self.uploadFiles == nil {
            self.uploadFiles = []
        }
        self.uploadFiles! += files
    }
    
    open func setFiles(_ files: [FileInfo]?) {
        self.uploadFiles = files
    }
    
    open func onError(_ errorCallback: FireErrorCallback?) {
        self.errorCallback = errorCallback
    }
    
    /**
     add a custom HTTP header to current hedaers
     
     - parameter key:   HTTP header key
     - parameter value: HTTP header value
     
     - returns: self (Fire object)
     */
    open func addHTTPHeader(_ value: String, forKey key: String) {
        self.extraHTTPHeaders.append((key, value))
    }
    
    /**
     add custom HTTP headers to current hedaers
     
     - parameter headers: HTTP header [key: value]
     
     - returns: self (Fire object)
     */
    open func addHTTPHeaders(_ headers: [String: String]) {
        for (key, value) in headers {
            self.extraHTTPHeaders.append((key, value))
        }
    }
    
    /**
     set custom HTTP headers to replace current headers
     
     - parameter headers: HTTP header [key: value]
     
     - returns: self (Fire object)
     */
    open func setHTTPHeaders(_ headers: [String: String]?) {
        self.cleanHTTPHeaders()
        if headers != nil {
            self.addHTTPHeaders(headers!)
        }
    }
    
    open func cleanHTTPHeaders() {
        self.extraHTTPHeaders.removeAll()
    }
    
    open func sethttpBody(raw: String, isJSON: Bool = false) {
        self.HTTPBodyRaw = raw
        self.HTTPBodyRawIsJSON = isJSON
    }
    
    open func setBasicAuth(_ auth: (String, String)) {
        self.basicAuth = auth
    }
    
    open func fire(_ callback: FireDataResponseCallback? = nil) {
        self.callback = callback
        
        self.buildRequest()
        self.buildHeader()
        self.buildBody()
        self.fireTask()
    }
    
    fileprivate func buildRequest() {
        if self.method == .GET && self.parameters?.count > 0 {
            self.request = URLRequest(url: URL(string: url + "?" + FireHelper.buildParams(self.parameters!))!)
        }
        self.request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        self.request.httpMethod = self.method.rawValue
    }
    
    fileprivate func buildHeader() {
        // multipart Content-Type; see http://www.rfc-editor.org/rfc/rfc2046.txt
        if self.parameters?.count > 0 {
            let f = ("Content-Type", "application/x-www-form-urlencoded")
            self.request.setValue(f.1, forHTTPHeaderField: f.0)
        }
        if self.uploadFiles?.count > 0 && self.method != .GET {
            let f = ("Content-Type", "multipart/form-data; boundary=" + self.boundary)
            self.request.setValue(f.1, forHTTPHeaderField: f.0)
        }
        if self.HTTPBodyRaw != "" {
            let f = ("Content-Type", self.HTTPBodyRawIsJSON ? "application/json" : "text/plain;charset=UTF-8")
            self.request.setValue(f.0, forHTTPHeaderField: f.1)
        }
        self.request.addValue(self.userAgent, forHTTPHeaderField: "User-Agent")
        if let auth = self.basicAuth {
            let authString = "Basic " + (auth.0 + ":" + auth.1).base64
            self.request.addValue(authString, forHTTPHeaderField: "Authorization")
        }
        for i in self.extraHTTPHeaders {
            self.request.setValue(i.1, forHTTPHeaderField: i.0)
        }
    }
    
    fileprivate func buildBody() {
        let data = NSMutableData()
        if self.HTTPBodyRaw != "" {
            let d1 = self.HTTPBodyRaw
            data.append(d1.nsdata as Data)
            if Fire.DEBUG {
                self.debugBody.append(d1)
            }
        } else if self.uploadFiles?.count > 0 {
            if self.method == .GET {
                print("\n\n------------------------\nThe remote server may not accept GET method with HTTP body. But Fire will send it anyway.\nIt looks like iOS 9 SDK has prevented sending http body in GET method.\n------------------------\n\n")
            } else {
                if let ps = self.parameters {
                    for (key, value) in ps {
                        let d1 = "--\(self.boundary)\r\n"
                        let d2 = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
                        let d3 = "\(value)\r\n"
                        data.append(d1.nsdata as Data)
                        data.append(d2.nsdata as Data)
                        data.append(d3.nsdata as Data)
                        if Fire.DEBUG {
                            self.debugBody.append(d1 + d2 + d3)
                        }
                    }
                }
                if let fs = self.uploadFiles {
                    for file in fs {
                        let d1 = "--\(self.boundary)\r\n"
                        let d2 = "Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.nameWithExt)\"\r\n"
                        data.append(d1.nsdata as Data)
                        data.append(d2.nsdata as Data)
                        let d3 = "Content-Type: \(file.mimeType)\r\n\r\n"
                        data.append(d3.nsdata as Data)
                        if Fire.DEBUG {
                            self.debugBody.append(d1 + d2 + d3)
                        }
                        if let fileurl = file.url {
                            if let a = try? Data(contentsOf: fileurl as URL) {
                                let d4 = "Data(" + fileurl.absoluteString + ")"
                                data.append(a)
                                let d5 = "\r\n"
                                data.append(d5.nsdata as Data)
                                if Fire.DEBUG {
                                    self.debugBody.append(d4 + d5)
                                }
                            }
                        } else if let filedata = file.data {
                            let d4 = "Data(file.data)"
                            data.append(filedata)
                            let d5 = "\r\n"
                            data.append(d5.nsdata as Data)
                            if Fire.DEBUG {
                                self.debugBody.append(d4 + d5)
                            }
                        }
                    }
                }
                let d6 = "--\(self.boundary)--\r\n"
                data.append(d6.nsdata as Data)
                if Fire.DEBUG {
                    self.debugBody.append(d6)
                }
            }
        } else if self.parameters?.count > 0 && self.method != .GET {
            let d7 = FireHelper.buildParams(self.parameters!)
            data.append(d7.nsdata)
            if Fire.DEBUG {
                self.debugBody.append(d7)
            }
        }
        self.request.httpBody = data as Data
        self.request.setValue("\(data.length)", forHTTPHeaderField: "Content-Length")
    }
    
    fileprivate func printReuestDebugInfo() {
        if Fire.DEBUG {
            let sep = "-----------------"
            var output: String = sep + "\n"
            output.append("[Fire] URL: " + self.url + "\n")
            output.append("[Fire] HTTP Method: " + self.method.rawValue + "\n")
            if let p = self.parameters {
                output.append("[Fire] Parameters:\n" + p.description + "\n")
            }
            if let a = self.request.allHTTPHeaderFields {
                output.append("[Fire] Request HEADERS:\n" + a.description + "\n")
            }
            if let data = self.request.httpBody {
                let s = "[Fire] Request Body:\n"
                if let d = String(data: data, encoding: String.Encoding.utf8) {
                    output.append(s + d)
                } else {
                    output.append(s + self.debugBody)
                }
            }
            print(output + "\n" + sep)
        }
    }
    
    fileprivate func printResponseDebugInfo(_ response: URLResponse?) {
        if Fire.DEBUG {
            if let a = response {
                print("[Fire] Response:\n", a.description)
            }
        }
    }
    
    public typealias URLSesstionDataCompletionHandler = ((Data?, URLResponse?, Error?) -> Swift.Void)
    public typealias URLSesstionURLCompletionHandler = ((URL?, URLResponse?, Error?) -> Swift.Void)
    
    fileprivate func fireTask() {
        
        self.printReuestDebugInfo()
        
        let dataCompletionHandler: URLSesstionDataCompletionHandler
//        let urlCompletionHandler: URLSesstionURLCompletionHandler
//
//        if self.taskType == .download {
//            dataCompletionHandler = { (data, response, error) -> Void in }
//            urlCompletionHandler = { [weak self] (url, response, error) -> Void in
//                
//                self?.printResponseDebugInfo(response)
//                
//                if let error = error as NSError? {
//                    if error.code == -999 {
//                        DispatchQueue.main.async {
//                            self?.cancelCallback?()
//                        }
//                    } else {
//                        let e = NSError(domain: self?.errorDomain ?? "Fire", code: error.code, userInfo: error.userInfo)
//                        print("[Fire] Error:\n", e.localizedDescription)
//                        DispatchQueue.main.async {
//                            self?.errorCallback?(e)
//                            self?.session.finishTasksAndInvalidate()
//                        }
//                    }
//                } else {
//                    DispatchQueue.main.async {
////                        self?.callback?(url, response as? HTTPURLResponse)
//                        self?.session.finishTasksAndInvalidate()
//                    }
//                }
//            }
//            
//        } else {
//            urlCompletionHandler = { (url, response, error) -> Void in }
            dataCompletionHandler = { [weak self] (data, response, error) -> Void in
                
                self?.printResponseDebugInfo(response)
                
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
                            self?.session.finishTasksAndInvalidate()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.callback?(data, response as? HTTPURLResponse)
                        self?.session.finishTasksAndInvalidate()
                    }
                }
            }
//        }
//        
//        switch self.taskType {
//        case .dataTask:
            self.task = self.session.dataTask(with: self.request, completionHandler: dataCompletionHandler)
//        case .uploadDataTask:
//            self.task = self.session.uploadTask(with: self.request, from: nil, completionHandler: dataCompletionHandler)
//        case .uploadFileTask:
//            self.task = self.session.uploadTask(with: self.request, fromFile: URL(string: "")!, completionHandler: dataCompletionHandler)
//        default:
//            self.task = self.session.downloadTask(with: self.request, completionHandler: urlCompletionHandler)
//        }
        self.task.resume()
    }
    
    open var progressCallback: FireProgressCallback?
}

extension FireManager: URLSessionTaskDelegate, URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) * 100
        if self.progressCallback != nil {
            self.progressCallback!(totalBytesWritten, totalBytesExpectedToWrite, progress)
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend) * 100
        if self.progressCallback != nil {
            self.progressCallback!(totalBytesSent, totalBytesExpectedToSend, progress)
        }
    }
}

extension FireManager {
    
    /**
     the only init method of FireManager
     
     - parameter method: HTTP request method
     - parameter url:    HTTP request url
     
     - returns: self (FireManager object)
     */
    static func build(_ method: HTTPMethod, url: String, timeout: Double = FireManager.oneMinute) -> FireManager {
        return FireManager(url: url, method: method, timeout: timeout)
    }
}

