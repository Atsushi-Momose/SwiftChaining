//
//  NotifierTests.swift
//

import XCTest
import Chaining

class NotifierTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testChainValue() {
        let notifier = Notifier<Int>()
        
        var received: Int?
        
        let observer = notifier.chain().do { received = $0 }.end()
        
        XCTAssertNil(received)
        
        notifier.notify(value: 3)
        
        XCTAssertEqual(received, 3)
        
        observer.invalidate()
    }
    
    func testChainVoid() {
        let notifier = Notifier<Void>()
        
        var received = false
        
        let observer = notifier.chain().do { received = true }.end()
        
        XCTAssertFalse(received)
        
        notifier.notify()
        
        XCTAssertTrue(received)
        
        observer.invalidate()
    }
    
    func testReceive() {
        let notifier = Notifier<Int>()
        let receivingNotifier = Notifier<Int>()
        
        let observer = notifier.chain().receive(receivingNotifier).end()
        
        var received: Int?
        let receivingObserver = receivingNotifier.chain().do { received = $0 }.end()
        
        notifier.notify(value: 1)
        
        XCTAssertEqual(received, 1)
        
        observer.invalidate()
        receivingObserver.invalidate()
    }
}
