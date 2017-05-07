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
//  String+Base64.swift
//  Fire
//
//  Created by Meniny on 15/10/7.
//

import Foundation

public extension String {
    /// return base64 string of self String
    public var base64: String? {
        if let utf8EncodeData = self.data(using: String.Encoding.utf8, allowLossyConversion: true) {
            let base64EncodingData = utf8EncodeData.base64EncodedString(options: [])
            return base64EncodingData
        }
        return nil
    }
}

public extension String {
    /// return NSData of self String
    public var data: Data {
        return self.data(using: String.Encoding.utf8)!
    }
}

public extension Dictionary {
    public var pretty: String {
        return "\(self as NSDictionary)"
    }
}

public extension Array {
    public var pretty: String {
        return "\(self as NSArray)"
    }
}
