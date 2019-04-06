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
                self.data = d as AnyObject?
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
                    let d = try JSONSerialization.data(withJSONObject: self.data as Any, options: .prettyPrinted)
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
            if let str = self.data as? NSString {
                return str.integerValue
            }
            return nil
        }
    }
    
    public var intValue: Int {
        get {
            return self.int ?? 0
        }
    }
    
    public var float: Float? {
        get {
            if let number = self.data as? NSNumber {
                return number.floatValue
            }
            if let number = self.data as? NSString {
                return number.floatValue
            }
            if let str = self.data as? NSString {
                return str.floatValue
            }
            return nil
        }
    }
    
    public var floatValue: Float {
        get {
            return self.float ?? 0.0
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
            if let str = self.data as? NSString {
                return str.doubleValue
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
            if let str = self.data as? String {
                return str
            }
            if let number = self.data as? NSNumber {
                return number.stringValue
            }
            if let bool = self.data as? Bool {
                return bool ? "true" : "false"
            }
            return nil
        }
    }
    
    public var stringValue: String {
        get {
            return self.string ?? ""
        }
    }
    
    public var bool: Bool? {
        get {
            if let bool = self.data as? Bool {
                return bool
            }
            if let number = self.data as? NSNumber {
                return number.intValue > 0
            }
            if let str = self.data as? NSString {
                if str == "true" {
                    return true
                }
                if str == "false" {
                    return false
                }
                return str.integerValue > 0
            }
            return nil
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
extension Jsonify: CustomStringConvertible {
    /// A textual representation of this instance.
    ///
    /// Instead of accessing this property directly, convert an instance of any
    /// type to a string by using the `String(describing:)` initializer. For
    /// example:
    ///
    ///     struct Point: CustomStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var description: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(describing: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `description` property.
    public var description: String {
        return rawValue
    }
}
extension Jsonify: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(JSONdata: elements as AnyObject?)
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
