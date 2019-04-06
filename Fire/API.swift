//
//  Fire.API.swift
//  Fire
//
//  Created by Meniny on 2016-04-19.
//  Copyright © 2016 Meniny. All rights reserved.
//

import Foundation
import Jsonify

public extension Fire {
    
    /// Simple API structure
    /// 
    ///     let api = Fire.API(appending: ...)
    ///     api.request(... { (_, _ , _) in 
    ///         // ...
    ///     })
    ///
    struct API: CustomStringConvertible {
        
        public static var baseURL: String?
        
        public var fullURL: String
        public let method: Fire.HTTPMethod// = Fire.HTTPMethod.GET
        public var headerFields: Fire.HeaderFields?// = nil
        public let successCode: Fire.ResponseStatus// = Fire.ResponseStatus.success
        public var defaultParameters: Fire.Params?
        
        public var ignoreBaseURL: Bool = false
        
        public init(useBaseURL: Bool = true, appending url: String, HTTPMethod method: Fire.HTTPMethod = .GET, params: Fire.Params? = nil, headers: Fire.HeaderFields? = nil, successCode: Fire.ResponseStatus = Fire.ResponseStatus.success) {
            self.ignoreBaseURL = !useBaseURL
            self.method = method
            self.defaultParameters = params
            self.headerFields = headers
            self.successCode = successCode
            self.fullURL = Fire.Helper.appendURL(url, to: useBaseURL ? Fire.API.baseURL : nil)
        }
        
        public var stringValue: String {
            return fullURL
        }
        
        public var description: String {
            return "[" + self.method.rawValue + ": \(self.successCode.rawValue)] " + self.stringValue
        }
        
        @discardableResult public func request(
            forType responseType: Fire.ResponseType,
            params: Fire.Params?,
            headers fields: Fire.HeaderFields? = nil,
            timeout: TimeInterval = FireDefaults.defaultTimeout,
            dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously,
            callback: Fire.GenericResponseCallback?,
            onError: Fire.ErrorCallback?
            ) -> Fire {
            
            return Fire.build(HTTPMethod: self.method, url: self.fullURL, timeout: timeout, dispatch: dispatch)
                .setParams(params)
                .addParams(self.defaultParameters)
                .addHTTPHeaders(fields)
                .onError(onError)
                .fire(forType: responseType, callback: callback)
        }
        
        @discardableResult public func requestJSON(
            params: Fire.Params?,
            headers fields: Fire.HeaderFields? = nil,
            timeout: TimeInterval = FireDefaults.defaultTimeout,
            dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously,
            callback: Fire.JOSNResponseCallback?,
            onError: Fire.ErrorCallback?
            ) -> Fire {
            return self.request(forType: .JSON, params: params, headers: fields, timeout: timeout, dispatch: dispatch, callback: { (json, resp, t) in
                if let cb = callback {
                    cb(json as! Jsonify, resp)
                }
            }, onError: onError)
        }
        
        @discardableResult public func requestData(
            params: Fire.Params?,
            headers fields: Fire.HeaderFields? = nil,
            timeout: TimeInterval = FireDefaults.defaultTimeout,
            dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously,
            callback: Fire.DataResponseCallback?,
            onError: Fire.ErrorCallback?
            ) -> Fire {
            return self.request(forType: .data, params: params, headers: fields, timeout: timeout, dispatch: dispatch, callback: { (json, resp, t) in
                if let cb = callback {
                    cb(json as? Data, resp)
                }
            }, onError: onError)
        }
        
        @discardableResult public func requestString(
            params: Fire.Params?,
            headers fields: Fire.HeaderFields? = nil,
            timeout: TimeInterval = FireDefaults.defaultTimeout,
            dispatch: Fire.Dispatch = Fire.Dispatch.asynchronously,
            callback: Fire.StringResponseCallback?,
            onError: Fire.ErrorCallback?
            ) -> Fire {
            return self.request(forType: .string, params: params, headers: fields, timeout: timeout, dispatch: dispatch, callback: { (json, resp, t) in
                if let cb = callback {
                    cb(json as? String, resp)
                }
            }, onError: onError)
        }
    }
}

