//
//  fireForJSON.swift
//  Fire
//
//  Created by Meniny on 15/10/10.
//  Copyright © 2015年 Meniny. All rights reserved.
//

import XCTest
import Fire

class fireForJSON: WithStringParams {
    
    func testfireForJSON() {
        let expectation = self.expectation(description: "testfireForJSON")
        
        Fire.build(HTTPMethod: .GET, url: "http://httpbin.org/get")
            .addParams([param1: param2, param2: param1])
            .onError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .fireForJSON({ (json, response) -> Void in
                XCTAssert(json["args"][self.param1].stringValue == self.param2)
                XCTAssert(json["args"][self.param2].stringValue == self.param1)
                
                expectation.fulfill()
            })
        
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
    
    func testfireForJSONWithValidBasicAuth() {
        let expectation = self.expectation(description: "testfireForJSONWithBasicAuth")
        
        Fire.build(HTTPMethod: .GET, url: "http://httpbin.org/basic-auth/user/passwd")
            .addParams([param1: param2, param2: param1])
            .setBasicAuth("user", password: "passwd")
            .onError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .fireForJSON { (json, response) -> Void in
                XCTAssert(json["authenticated"].boolValue)
                XCTAssert(json["user"].stringValue == "user")
                
                expectation.fulfill()
        }
        
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
    
    func testfireForJSONWithInValidBasicAuth() {
        let expectation = self.expectation(description: "testfireForJSONWithBasicAuth")
        
        Fire.build(HTTPMethod: .GET, url: "http://httpbin.org/basic-auth/user/passwd")
            .addParams([param1: param2, param2: param1])
        .setBasicAuth("foo", password: "bar")
            .onError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .fireForJSON { (json, response) -> Void in
                XCTAssertNotEqual(response?.statusCode, 200, "Basic Auth should get HTTP status 200")
                XCTAssert(json["authenticated"].boolValue == false)
                
                expectation.fulfill()
        }
        
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }

}
