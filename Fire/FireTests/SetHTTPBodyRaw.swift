//
//  SetHTTPBodyRaw.swift
//  Fire
//
//  Created by Meniny on 15/10/11.
//  Copyright © 2015年 Meniny. All rights reserved.
//

import XCTest
import Fire

class SetHTTPBodyRawTests: BaseTestCase {
    
    func testSetHTTPBodyRawString() {
        let expectation = self.expectation(description: "testSetHTTPBodyRawString")
        let rawString = self.randomStringWithLength(20)
        Fire.build(HTTPMethod: .POST, url: "http://httpbin.org/post")
            .setHTTPBodyRaw(rawString)
            .onError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .fireForJSON { (json, response) -> Void in
                XCTAssertEqual(json["data"].stringValue, rawString)
                expectation.fulfill()
        }
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
    
    func testSetHTTPBodyRawJSON() {
        let expectation = self.expectation(description: "testSetHTTPBodyRawString")
        
        let string1 = self.randomStringWithLength(20)
        let string2 = self.randomStringWithLength(20)
        let j = FireJSON(dictionary: ["string1": string1, "string2": string2])

        Fire.build(HTTPMethod: .POST, url: "http://httpbin.org/post")
            .setHTTPBodyRaw(j.rawValue, isJSON: true)
            .onError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .fireForJSON { (json, response) -> Void in
                XCTAssertEqual(json["data"].stringValue, j.rawValue)
                XCTAssertEqual(json["json"]["string1"].stringValue, string1)
                XCTAssertEqual(json["json"]["string2"].stringValue, string2)
                expectation.fulfill()
        }
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
}
