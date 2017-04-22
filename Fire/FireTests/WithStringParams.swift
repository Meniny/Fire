//
//  WithParams.swift
//  Fire
//
//  Created by Meniny on 15/10/8.
//  Copyright © 2015年 Meniny. All rights reserved.
//

import XCTest
import Fire

class WithStringParams: BaseTestCase {
    
    var param1: String!
    var param2: String!
    
    override func setUp() {
        super.setUp()
        
        self.param1 = randomStringWithLength(200)
        self.param2 = randomStringWithLength(200)
    }
    
    func testGETWithParams() {
        let expectation = self.expectation(description: "testGETWithParams")
        
        Fire.build(HTTPMethod: .GET, url: "http://staticonsae.sinaapp.com/Fire.php")
            .addParams(["get": param1, "get2": param2])
            .onError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .fireForString { (string, response) -> Void in
                XCTAssert(string == self.param1 + self.param2, "GET should success and return the strings together")
                
                expectation.fulfill()
        }
        
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
    
    func testPOSTWithParams() {
        let expectation = self.expectation(description: "testPOSTWithParams")
        
        Fire.build(HTTPMethod: .POST, url: "http://staticonsae.sinaapp.com/Fire.php")
            .addParams(["post": param1, "post2": param2])
            .onError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .fireForString({ (string, response) -> Void in
                XCTAssert(string == self.param1 + self.param2, "GET should success and return the strings together")
                
                expectation.fulfill()
            })
        
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
}
