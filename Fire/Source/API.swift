//
//  Fire.API.swift
//  Fire
//
//  Created by Meniny on 2016-04-19.
//  Copyright © 2016 Meniny. All rights reserved.
//

import Foundation

public extension Fire {
    public struct API: CustomStringConvertible {
        public static var baseURL: String?
        public var fullURL: String?
        public var method: Fire.HTTPMethod = .GET
        public var successCode: Fire.ResponseStatus = .success
        
        public init(appending url: String, HTTPMethod method: Fire.HTTPMethod = .GET, successCode: Fire.ResponseStatus = .success) {
            self.method = method
            self.successCode = successCode
            if Fire.API.baseURL == nil {
                self.fullURL = url
            } else {
                let sep = "/"
                if Fire.API.baseURL!.hasSuffix(sep) {
                    if url.hasPrefix(sep) {
                        self.fullURL = Fire.API.baseURL! + url.substring(from: url.index(url.startIndex, offsetBy: 1))
                    } else {
                        self.fullURL = Fire.API.baseURL! + url
                    }
                } else {
                    if url.hasPrefix(sep) {
                        self.fullURL = Fire.API.baseURL! + url
                    } else {
                        self.fullURL = Fire.API.baseURL! + sep + url
                    }
                }
            }
        }
        
        public var stringValue: String {
            return fullURL ?? ""
        }
        
        public var description: String {
            return "[" + self.method.rawValue + "] " + self.stringValue
        }
    }
}

