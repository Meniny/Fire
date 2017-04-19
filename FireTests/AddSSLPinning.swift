//
//  AddSSLPinningTests.swift
//  Fire
//
//  Created by Meniny on 15/10/6.
//  Copyright © 2015年 Meniny. All rights reserved.
//

import XCTest
import Fire

class AddSSLPinning: BaseTestCase {
    
    var certData: Data!
    var certData1: Data!
    var certData2: Data!
    
    override func setUp() {
        super.setUp()
        self.certData = try! Data(contentsOf: self.URLForResource("meninycn", withExtension: "cer"))
        self.certData1 = try! Data(contentsOf: self.URLForResource("logo@2x", withExtension: "jpg"))
        self.certData2 = "Fire".data(using: String.Encoding.utf8)
    }
    
    func testSSLPiningPassed() {
        let expectation = self.expectation(description: "testSSLPiningPassed")
        
        Fire.build(HTTPMethod: .GET, url: "https://meniny.cn/")
            .addSSLPinning(LocalCertData: self.certData, SSLValidateErrorCallBack: { () -> Void in
                XCTFail("Under the Man-in-the-middle attack!")
            })
            .onNetworkError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .responseString { (string, response) -> Void in
                XCTAssert((string?.lengthOfBytes(using: String.Encoding.utf8))! > 0)
                
                expectation.fulfill()
        }
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
    
    func testSSLPiningArrayPassed() {
        let expectation = self.expectation(description: "testSSLPiningArrayPassed")
        
        Fire.build(HTTPMethod: .GET, url: "https://meniny.cn/")
            .addSSLPinning(LocalCertDataArray: [self.certData1, self.certData2, self.certData], SSLValidateErrorCallBack: { () -> Void in
                XCTFail("Under the Man-in-the-middle attack!")
            })
            .onNetworkError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .responseString { (string, response) -> Void in
                XCTAssert((string?.lengthOfBytes(using: String.Encoding.utf8))! > 0)
                
                expectation.fulfill()
        }
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
    
    func testSSLPiningArrayNotPassed() {
        let expectation = self.expectation(description: "testSSLPiningArrayNotPassed")
        var errorPinning = 0
        
        Fire.build(HTTPMethod: .GET, url: "https://meniny.cn/")
            .addSSLPinning(LocalCertDataArray: [self.certData1, self.certData2], SSLValidateErrorCallBack: { () -> Void in
                print("Under the Man-in-the-middle attack!")
                errorPinning = 1
                expectation.fulfill()
            })
            .onNetworkError({ (error) -> Void in
                XCTAssertNotNil(error)
                XCTAssert(errorPinning == 1, "Under the Man-in-the-middle attack")
            })
            .responseString { (string, response) -> Void in
                XCTFail("shoud not run callback() after a Man-in-the-middle attack.")
        }
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
    
    func testSSLPiningNotPassed() {
        let expectation = self.expectation(description: "testSSLPiningNotPassed")
        var errorPinning = 0
        
        Fire.build(HTTPMethod: .GET, url: "https://autolayout.club/")
            .addSSLPinning(LocalCertData: self.certData, SSLValidateErrorCallBack: { () -> Void in
                print("Under the Man-in-the-middle attack!")
                errorPinning = 1
                expectation.fulfill()
            })
            .onNetworkError({ (error) -> Void in
                XCTAssertNotNil(error)
                XCTAssert(errorPinning == 1, "Under the Man-in-the-middle attack")
            })
            .responseString { (string, response) -> Void in
                XCTFail("shoud not run callback() after a Man-in-the-middle attack.")
        }
        
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
    
    func testSSLPiningNil() {
        let expectation = self.expectation(description: "testSSLPiningPassed")
        
        Fire.build(HTTPMethod: .GET, url: "https://meniny.cn/")
            .onNetworkError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .responseString { (string, response) -> Void in
                XCTAssert((string?.lengthOfBytes(using: String.Encoding.utf8))! > 0)
                
                expectation.fulfill()
        }
        waitForExpectations(timeout: self.defaultTimeout, handler: nil)
    }
    
}
