//
//  FireAPI.swift
//  Fire
//
//  Created by Meniny on 2017-04-19.
//  Copyright © 2017年 Meniny. All rights reserved.
//

import Foundation

open class FireAPI: CustomStringConvertible {
    open static var baseURL: String?
    open var fullURL: String?
    open var method: HTTPMethod = .GET
    
    public init(appending url: String, HTTPMethod method: HTTPMethod = .GET) {
        self.method = method
        if FireAPI.baseURL == nil {
            self.fullURL = url
        } else {
            let sep = "/"
            if FireAPI.baseURL!.hasSuffix(sep) {
                if url.hasPrefix(sep) {
                    self.fullURL = FireAPI.baseURL! + url.substring(from: url.index(url.startIndex, offsetBy: 1))
                } else {
                    self.fullURL = FireAPI.baseURL! + url
                }
            } else {
                if url.hasPrefix(sep) {
                    self.fullURL = FireAPI.baseURL! + url
                } else {
                    self.fullURL = FireAPI.baseURL! + sep + url
                }
            }
        }
    }
    
    open var stringValue: String {
        return fullURL == nil ? "" : fullURL!
    }
    
    open var description: String {
        return "[" + self.method.rawValue + "] " + self.stringValue
    }
}
