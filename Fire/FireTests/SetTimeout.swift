//
//  SetTimeout.swift
//  Fire
//
//  Created by Meniny on 17/2/20.
//  Copyright © 2017年 Meniny. All rights reserved.
//

import XCTest
import Fire

class SetTimeout: BaseTestCase {
    
    func testSetTimeoutSuccess() {
        let expectation = self.expectation(description: "testSetTimeoutSuccess")

        Fire.build(HTTPMethod: .GET, url: "http://httpbin.org/delay/5", timeout: 8)
            .onError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .fireForJSON { (json, response) -> Void in
                XCTAssertEqual(json["url"].stringValue, "http://httpbin.org/delay/5")
                expectation.fulfill()
        }
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
    
    func testSetTimeoutFail() {
        let expectation = self.expectation(description: "testSetTimeoutFail")
        
        Fire.build(HTTPMethod: .GET, url: "http://httpbin.org/delay/5", timeout: 2)
            .onError({ (error) -> Void in
                expectation.fulfill()
            })
            .fireForJSON { (json, response) -> Void in
                XCTAssertEqual(json["url"].stringValue, "http://httpbin.org/delay/5")
        }
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
}
