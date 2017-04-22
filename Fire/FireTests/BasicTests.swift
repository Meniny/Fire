//
//  BasicTests.swift
//  Fire
//
//  Created by Meniny on 15/10/8.
//  Copyright © 2015年 Meniny. All rights reserved.
//

import XCTest
import Fire

class BasicTests: BaseTestCase {

    func testGET() {
        let expectation = self.expectation(description: "testGET")
        
        Fire.build(HTTPMethod: .GET, url: "http://staticonsae.sinaapp.com/Fire.php")
            .onError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .fireForString { (string, response) -> Void in
                XCTAssert(string == "", "GET should success and return empty string with no params")
                
                expectation.fulfill()
        }
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
    
    func testPOST() {
        let expectation = self.expectation(description: "testPOST")
        
        Fire.build(HTTPMethod: .POST, url: "http://staticonsae.sinaapp.com/Fire.php")
            .onError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .fireForString { (string, response) -> Void in
                XCTAssert(string == "", "POST should success and return empty string with no params")
                
                expectation.fulfill()
        }
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
    
    func testOneMoreThing() {
        // code here will not be used in reality forever, just for increasing testing coverage
        
        let expectation = self.expectation(description: "testOneMoreThing")
        Fire.DEBUG = true
        Fire.build(HTTPMethod: .GET, url: "http://staticonsae.sinaapp.com/Fire.php")
            .fireForString { (string, response) -> Void in
                XCTAssert(string == "", "GET should success and return empty string with no params")
                
                expectation.fulfill()
        }
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
}
