//
//  FileClientTests.swift
//  FileClientDemoTests
//
//  Created by Jean Raphael Bordet on 22/06/2020.
//

import XCTest
import FileClient

class FileClientTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_save_success() {
        let userfileClient = UserFileClient.test
        
        let user = User(name: "jR", age: 35)
                                
        switch userfileClient.persist([user]) {
        case let .success(value):
            XCTAssert(value)
        case let .failure(e):
            fatalError(e.localizedDescription)
        }
        
        switch userfileClient.retrieve() {
        case let .success(result):
            XCTAssertEqual(result, [user])
        case let .failure(e):
            fatalError(e.localizedDescription)
        }
    }
    
    func test_save_collection_success() {
        let userfileClient = UserFileClient.test
        
        let user = User.collection
                                
        switch userfileClient.persist(user) {
        case let .success(value):
            XCTAssert(value)
        case let .failure(e):
            fatalError(e.localizedDescription)
        }

        switch userfileClient.retrieve() {
        case let .success(result):
            XCTAssertEqual(result, user)
        case let .failure(e):
            fatalError(e.localizedDescription)
        }
    }
    
    func test_file_client_empty_fileName() {
        let userfileClient = UserFileClient.failure
        
        let user = User(name: "jR", age: 35)
                                
        switch userfileClient.persist([user]) {
        case let .success(value):
            XCTAssert(value)
        case let .failure(e):
            XCTAssertEqual(e, .generic("fileName is empty"))
        }
        
        switch userfileClient.retrieve() {
        case let .success(result):
            XCTAssertEqual(result, [user])
        case let .failure(e):
            XCTAssertEqual(e, .generic("unbale to load data from empty fileName"))
        }
    }
}
