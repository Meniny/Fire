//
//  AddHTTPHeader.swift
//  Fire
//
//  Created by Meniny on 15/10/16.
//  Copyright © 2015年 Meniny. All rights reserved.
//

import XCTest
import Fire

class AddHTTPHeader: BaseTestCase {
    
    func testAddHTTPHeader() {
        let expectation = self.expectation(description: "testAddHTTPHeader")
        
        let name = "Accept"
        let value = "application/json"

        Fire.build(HTTPMethod: .GET, url: "http://httpbin.org/headers")
            .setHTTPHeader(Name: name, Value: value)
            .onNetworkError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .responseJSON { (json, response) -> Void in
                XCTAssertEqual(json["headers"][name].stringValue, value)
                expectation.fulfill()
        }
        
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
}
