//
//  Control.swift
//  Fire
//
//  Created by Meniny on 15/12/25.
//  Copyright © 2015年 Meniny. All rights reserved.
//

import XCTest
import Fire

class Control: BaseTestCase {
    
    func testCancel() {
        let expectation = self.expectation(description: "testCancel")
        
        let fire = Fire.build(HTTPMethod: .GET, url: "http://httpbin.org/")
            .onNetworkError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
        fire.responseString { (string, response) -> Void in
            XCTFail("the request should be cancelled")
            
            expectation.fulfill()
        }
        fire.cancel { () -> Void in
            expectation.fulfill()
        }
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
    
}
