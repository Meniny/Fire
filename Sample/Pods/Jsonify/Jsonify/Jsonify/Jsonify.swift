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
//  Jsonify.swift
//  Jsonify 
//
//  Created by Meniny on 15/10/7.
//

import Foundation

public struct Jsonify {
    
    public static var DEBUG = false
    
    public var data: Any!
    
    // MARK: - Init
    public init(string: String, encoding: String.Encoding = String.Encoding.utf8) {
        do {
            if let data = string.data(using: encoding) {
                let d = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                self.data = d as AnyObject!
            }
        } catch let error as NSError {
            if Jsonify.DEBUG {
                let e = NSError(domain: "Jsonify.JSONParseError", code: error.code, userInfo: error.userInfo)
                print(e.localizedDescription)
            }
        }
    }

    fileprivate init(any: AnyObject) {
        let j: Jsonify = [any]
        self.data = j.arrayValue.first?.data
    }
    
    internal init(JSONdata: AnyObject!) {
        self.data = JSONdata
    }
    
    public init() {
        self.init(JSONdata: nil)
    }
    
    public init(dictionary: [String: Any]) {
        self.init(any: dictionary as AnyObject)
    }
    
    public init(array: [Any]) {
        self.init(any: array as AnyObject)
    }
}

// MARK: - Subscript
extension Jsonify {
    public subscript (index: String) -> Jsonify {
        if let jsonDictionary = self.data as? Dictionary<String, AnyObject> {
            if let value = jsonDictionary[index] {
                return Jsonify(JSONdata: value)
            } else {
                if Jsonify.DEBUG {
                    print("Jsonify: No such key '\(index)'")
                }
            }
        }
        return Jsonify(JSONdata: nil)
    }
}

// MARK: - Getting Values
extension Jsonify {
    public var raw: String? {
        get {
            if let _ = self.data {
                do {
                    let d = try JSONSerialization.data(withJSONObject: self.data, options: .prettyPrinted)
                    return NSString(data: d, encoding: String.Encoding.utf8.rawValue) as String?
                } catch { return nil }
            }
            return nil
        }
    }
    
    public var rawValue: String {
        get {
            return self.raw ?? ""
        }
    }
    
    public var int: Int? {
        get {
            if let number = self.data as? NSNumber {
                return number.intValue
            }
            if let number = self.data as? NSString {
                return number.integerValue
            }
            return nil
        }
    }
    
    public var intValue: Int {
        get {
            return self.int ?? 0
        }
    }
    
    public var double: Double? {
        get {
            if let number = self.data as? NSNumber {
                return number.doubleValue
            }
            if let number = self.data as? NSString {
                return number.doubleValue
            }
            return nil
        }
    }
    
    public var doubleValue: Double {
        get {
            return self.double ?? 0.0
        }
    }
    
    public var string: String? {
        get {
            return self.data as? String
        }
    }
    
    public var stringValue: String {
        get {
            return self.string ?? ""
        }
    }
    
    public var bool: Bool? {
        get {
            return self.data as? Bool
        }
    }
    
    public var boolValue: Bool {
        get {
            return self.bool ?? false
        }
    }
    
    public var array: [Jsonify]? {
        get {
            if let _ = self.data {
                if let arr = self.data as? [AnyObject] {
                    var result: [Jsonify] = []
                    for i in arr {
                        result.append(Jsonify(JSONdata: i))
                    }
                    return result
                }
                return nil
            }
            return nil
        }
    }
    public var arrayValue: [Jsonify] {
        get {
            return self.array ?? []
        }
    }
}

// MARK: - Convertible
extension Jsonify: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(JSONdata: elements as AnyObject!)
    }
}

extension Jsonify: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        let data = elements.reduce([String: Any]()){(dictionary: [String: Any], element:(String, Any)) -> [String: Any] in
            var d = dictionary
            d[element.0] = element.1
            return d
        }
        self.init(JSONdata: data as AnyObject)
    }
}
