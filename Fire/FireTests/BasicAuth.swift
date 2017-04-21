//
//  BasicAuthTests.swift
//  Fire
//
//  Created by Meniny on 15/10/8.
//  Copyright © 2015年 Meniny. All rights reserved.
//

import XCTest
import Fire

class BasicAuth: BaseTestCase {
    
    func testValidBasicAuth() {
        let expectation = self.expectation(description: "testBasicAuth")
        Fire.build(HTTPMethod: .GET, url: "http://httpbin.org/basic-auth/user/passwd")
            .setBasicAuth("user", password: "passwd")
            .onNetworkError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .responseData { (data, response) -> Void in
                XCTAssertEqual(response?.statusCode ?? 0, 200, "Basic Auth should get HTTP status 200")
                
                expectation.fulfill()
        }
        
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
    
    func testInValidBasicAuth() {
        let expectation = self.expectation(description: "testInValidBasicAuth")
        Fire.build(HTTPMethod: .GET, url: "http://httpbin.org/basic-auth/user/passwd")
            .setBasicAuth("foo", password: "bar")
            .onNetworkError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .responseData { (data, response) -> Void in
                XCTAssertNotEqual(response?.statusCode, 200, "Basic Auth should get HTTP status 200")
                
                expectation.fulfill()
        }
        
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
}
