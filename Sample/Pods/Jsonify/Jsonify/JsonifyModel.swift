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
//  JsonifyModel.swift
//  Jsonify 
//
//  Created by Meniny on 15/10/3.
//

import Foundation

open class JsonifyModel: NSObject {
    
    open var JsonifyObject: Jsonify?
    
    public override init() {
        super.init()
    }
    
    public init(JSONString string: String, encoding: String.Encoding = String.Encoding.utf8) {
        let jsonnd = Jsonify(string: string, encoding: encoding)
        self.JsonifyObject = jsonnd
        super.init()
        self.mapValues()
    }
    
    public convenience init(string: String, encoding: String.Encoding = String.Encoding.utf8) {
        self.init(JSONString: string, encoding: encoding)
    }
    
    public init(JsonifyObject json: Jsonify) {
        self.JsonifyObject = json
        super.init()
        self.mapValues()
    }
    
    public convenience init(json: Jsonify) {
        self.init(JsonifyObject: json)
    }
    
    internal func mapValues() {
        let mirror = Mirror(reflecting: self)
        for (k, v) in AnyRandomAccessCollection(mirror.children)! {
            if let key = k, let jSONNDObject = self.JsonifyObject {
                let json = jSONNDObject[key]
                var valueWillBeSet: Any?
                switch v {
                case _ as String:
                    valueWillBeSet = json.stringValue
                case _ as Int:
                    valueWillBeSet = json.intValue
                case _ as Double:
                    valueWillBeSet = json.doubleValue
                case _ as Float:
                    valueWillBeSet = json.floatValue
                case _ as Bool:
                    valueWillBeSet = json.boolValue
                default:
                    continue
                }
                self.setValue(valueWillBeSet, forKey: key)
            }
        }
    }
    
    open var raw: String? {
        get {
            return self.JsonifyObject?.raw
        }
    }

    open var rawValue: String {
        get {
            return self.raw ?? ""
        }
    }
    
    open var jsonify: Jsonify? {
        get {
            if let json = JsonifyObject {
                return json
            }
            guard let r = raw else {
                return nil
            }
            return Jsonify(string: r)
        }
    }
    
    open var jsonifyValue: Jsonify {
        get {
            if let json = JsonifyObject {
                return json
            }
            return Jsonify(string: rawValue)
        }
    }
}
