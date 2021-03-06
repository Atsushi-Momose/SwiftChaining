//
//  GuardTests.swift
//

import XCTest
import Chaining

class GuardTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGuard() {
        let notifier = Notifier<Int>()
        
        var received: Int?
        
        let observer = notifier.chain().guard { return $0 > 0 }.do { received = $0 }.end()
        
        notifier.notify(value: 0)
        
        // 0以下なので呼ばれない
        XCTAssertNil(received)
        
        notifier.notify(value: 1)
        
        // 0より大きいので呼ばれる
        XCTAssertEqual(received, 1)
        
        observer.invalidate()
    }
}
