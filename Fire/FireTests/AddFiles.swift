//
//  AddFiles.swift
//  Fire
//
//  Created by Meniny on 15/10/8.
//  Copyright © 2015年 Meniny. All rights reserved.
//

import XCTest
import Fire

class AddFiles: BaseTestCase {
    
    func testAddOneFile() {
        let file = FileInfo(name: "file", url: self.URLForResource("logo@2x", withExtension: "jpg"))
        
        let expectation = self.expectation(description: "testAddOneFile")
        Fire.build(HTTPMethod: .POST, url: "http://staticonsae.sinaapp.com/Fire.php")
            .addParams(["param": "test"])
            .addFiles([file])
            .onError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .fireForString({ (string, response) -> Void in
                XCTAssert(string == "1", "file uploaded error!")
                
                expectation.fulfill()
            })
        
        waitForExpectations(timeout: self.defaultFileUploadTimeout, handler: nil)
    }
    
    func testAddOneFileInData() {
        let data = try! Data(contentsOf: self.URLForResource("logo@2x", withExtension: "jpg"))
        let file = FileInfo(name: "file", data: data, type: "jpg")
        
        let expectation = self.expectation(description: "testAddOneFileInData")
        Fire.build(HTTPMethod: .POST, url: "http://staticonsae.sinaapp.com/Fire.php")
            .addParams(["param": "test"])
            .addFiles([file])
            .onError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .fireForString({ (string, response) -> Void in
                XCTAssert(string == "1", "file uploaded error!")
                
                expectation.fulfill()
            })
        
        waitForExpectations(timeout: self.defaultFileUploadTimeout, handler: nil)
    }
    
    func testOneMoreThing() {
        // code here will not be used in reality forever, just for increasing testing coverage
        
        let file = FileInfo(name: "file", url: self.URLForResource("logo@2x", withExtension: "jpg"))
        
        let expectation = self.expectation(description: "testOneMoreThing")
        Fire.build(HTTPMethod: .GET, url: "http://staticonsae.sinaapp.com/Fire.php")
            .addFiles([file])
            .onError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .fireForData { (data, response) -> Void in
                expectation.fulfill()
        }
        
        waitForExpectations(timeout: self.defaultFileUploadTimeout, handler: nil)
    }
    
    func testOneMoreThingInData() {
        // code here will not be used in reality forever, just for increasing testing coverage
        
        let data = try! Data(contentsOf: self.URLForResource("logo@2x", withExtension: "jpg"))
        let file = FileInfo(name: "file", data: data, type: "jpg")
        
        let expectation = self.expectation(description: "testOneMoreThingInData")
        Fire.build(HTTPMethod: .GET, url: "http://staticonsae.sinaapp.com/Fire.php")
            .addFiles([file])
            .onError({ (error) -> Void in
                XCTAssert(false, error.localizedDescription)
            })
            .fireForData { (data, response) -> Void in
                expectation.fulfill()
        }
        
        waitForExpectations(timeout: self.defaultFileUploadTimeout, handler: nil)
    }
}
