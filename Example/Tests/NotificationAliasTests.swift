//
//  NotificationAliasTests.swift
//

import XCTest
import Chaining

extension Notification.Name {
    fileprivate static let testNotification = NSNotification.Name("TestNotification")
}

fileprivate class TestPostObject {
    func post() {
        NotificationCenter.default.post(name: .testNotification, object: self)
    }
}

class NotificationAliasTests: XCTestCase {
    var pool = ObserverPool()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        self.pool.invalidate()
        super.tearDown()
    }

    func testNotificationAlias() {
        let postObj = TestPostObject()
        
        let alias = NotificationAlias(.testNotification, object: postObj)
        
        var received: TestPostObject?
        
        self.pool += alias.chain().do { value in received = value.object as? TestPostObject }.end()
        
        postObj.post()
        
        XCTAssertNotNil(received)
        XCTAssertEqual(ObjectIdentifier(received!), ObjectIdentifier(postObj))
    }
    
    func testInvalidate() {
        let postObj = TestPostObject()
        
        let alias = NotificationAlias(.testNotification, object: postObj)
        
        var received: TestPostObject?
        
        self.pool += alias.chain().do { value in received = value.object as? TestPostObject }.end()
        
        alias.invalidate()
        
        postObj.post()
        
        XCTAssertNil(received)
    }
    
    func testDeinit() {
        let postObj = TestPostObject()
        
        var received: TestPostObject?
        
        do {
            let alias = NotificationAlias(.testNotification, object: postObj)
            
            self.pool += alias.chain().do { value in received = value.object as? TestPostObject }.end()
            
            postObj.post()
            
            XCTAssertNotNil(received)
            
            received = nil
        }
        
        postObj.post()
        
        XCTAssertNil(received)
    }
}
