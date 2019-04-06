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
//  Fire.Helper.swift
//  Fire
//
//  Created by Meniny on 15/10/7.
//

import Foundation

public extension Fire {

    struct Helper {
        
        public static func appendURL(_ appending: String, to baseURL: String?) -> String {
            if let base = baseURL {
                let sep = "/"
                if base.hasSuffix(sep) {
                    if appending.hasPrefix(sep) {
                        return base + appending[appending.index(appending.startIndex, offsetBy: 1)..<appending.endIndex]
//                        return base + appending.substring(from: appending.index(appending.startIndex, offsetBy: 1))
                    }
                    return base + appending
                }
                
                if appending.hasPrefix(sep) {
                    return base + appending
                }
                return base + sep + appending
            }
            return appending
        }
        
        public static func buildParams(_ parameters: [String: Any]) -> String {
            var components: [(String, String)] = []
            for key in Array(parameters.keys).sorted(by: <) {
                let value = parameters[key]
                components += Fire.Helper.queryComponents(key, value ?? "value_is_nil")
            }
            
            return components.map{"\($0)=\($1)"}.joined(separator: "&")
        }
        
        public static func queryComponents(_ key: String, _ value: Any) -> [(String, String)] {
            var components: [(String, String)] = []
            var valueString = ""
            
            switch value {
            case _ as String:
                valueString = value as! String
            case _ as Bool:
                valueString = (value as! Bool).description
            case _ as Double:
                valueString = (value as! Double).description
            case _ as Int:
                valueString = (value as! Int).description
            default:
                break
            }
            
            components.append(contentsOf: [(Fire.Helper.escape(key), Fire.Helper.escape(valueString))])
            return components
        }
        
        public static func escape(_ string: String) -> String {
            if #available(iOS 10.0, macOS 10.12, *) {
                if let esc = string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                    return esc
                }
                return string
            } else {
                let chars = ":&=;+!@#$()',*"
                let legalURLCharactersToBeEscaped: CFString = chars as CFString
                return CFURLCreateStringByAddingPercentEscapes(nil, string as CFString?, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
            }
        }
    }
}

public extension String {
    /// return base64 string of self String
    var base64: String? {
        if let utf8EncodeData = self.data(using: String.Encoding.utf8, allowLossyConversion: true) {
            let base64EncodingData = utf8EncodeData.base64EncodedString(options: [])
            return base64EncodingData
        }
        return nil
    }
}

public extension String {
    
    var unicodeCharactersDecodedString: String? {
        let tempString = self.replacingOccurrences(of: "\\u", with: "\\U").replacingOccurrences(of:"\"", with: "\\\"")
        if let tempData = "\"\(tempString)\"".data(using: .utf8) {
            if let res = try? PropertyListSerialization.propertyList(from: tempData, options: [], format: nil) {
                return res as? String
            }
        }
        return nil
    }
}

public extension String {
    /// return NSData of self String
    var data: Data {
        return self.data(using: String.Encoding.utf8)!
    }
}

public extension Dictionary {
    var pretty: String {
        return "\(self as NSDictionary)"
    }
}

public extension Array {
    var pretty: String {
        return "\(self as NSArray)"
    }
}
