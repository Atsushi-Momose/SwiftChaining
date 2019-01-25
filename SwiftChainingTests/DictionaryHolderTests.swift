//
//  DictionaryHolderTests.swift
//

import XCTest
import Chaining

class DictionaryHolderTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInit() {
        let dictionary = DictionaryHolder<Int, String>()
        
        XCTAssertEqual(dictionary.rawDictionary, [:])
    }
    
    func testSetDictionaryWithRelayableValue() {
        let dictionary = DictionaryHolder([10: "10", 20: "20"])
        
        XCTAssertEqual(dictionary.rawDictionary, [10: "10", 20: "20"])
        
        dictionary.set([30: "30", 40: "40", 50: "50"])
        
        XCTAssertEqual(dictionary.rawDictionary, [30: "30", 40: "40", 50: "50"])
    }
    
    func testSetDictionaryWithSendableValue() {
        let holder1 = Holder(1)
        let holder2 = Holder(2)
        let holder3 = Holder(3)
        
        let dictionary = DictionaryHolder([1: holder1, 2: holder2])
        
        XCTAssertEqual(dictionary.rawDictionary.count, 2)
        XCTAssertEqual(dictionary[1], Holder(1))
        XCTAssertEqual(dictionary[2], Holder(2))
        
        dictionary.set([3: holder3])
        
        XCTAssertEqual(dictionary.count, 1)
        XCTAssertEqual(dictionary[3], Holder(3))

    }

    func testReplaceValueWithRelayableValue() {
        let dictionary = DictionaryHolder([10: "10", 20: "20", 30: "30"])

        XCTAssertEqual(dictionary.rawDictionary, [10: "10", 20: "20", 30: "30"])

        dictionary.replace(key: 20, value: "200")

        XCTAssertEqual(dictionary.rawDictionary, [10: "10", 20: "200", 30: "30"])
        
        dictionary[30] = "300"
        
        XCTAssertEqual(dictionary.rawDictionary, [10: "10", 20: "200", 30: "300"])
    }

    func testReplaceValueWithSendableValue() {
        let holder1 = Holder(1)
        let holder2 = Holder(2)
        let holder3 = Holder(3)
        let holder2b = Holder(22)
        let holder3b = Holder(33)

        let dictionary = DictionaryHolder([1: holder1, 2: holder2, 3: holder3])

        XCTAssertEqual(dictionary.rawDictionary, [1: holder1, 2: holder2, 3: holder3])

        dictionary.replace(key: 2, value: holder2b)

        XCTAssertEqual(dictionary.count, 3)
        XCTAssertEqual(dictionary.rawDictionary, [1: holder1, 2: holder2b, 3: holder3])
        
        dictionary[3] = holder3b
        
        XCTAssertEqual(dictionary.rawDictionary, [1: holder1, 2: holder2b, 3: holder3b])
    }

    func testRemoveValue() {
        let array = DictionaryHolder([1: "1", 2: "2", 3: "3"])

        let removed2 = array.removeValue(forKey: 2)

        XCTAssertEqual(array.count, 2)
        XCTAssertEqual(array.rawDictionary, [1: "1", 3: "3"])
        XCTAssertEqual(removed2, "2")
        
        let removed4 = array.removeValue(forKey: 4)
        
        XCTAssertEqual(array.count, 2)
        XCTAssertEqual(array.rawDictionary, [1: "1", 3: "3"])
        XCTAssertNil(removed4)
    }

    func testRemoveAll() {
        let dictionary = DictionaryHolder([1: "1", 2: "2", 3: "3"])

        dictionary.removeAll()

        XCTAssertEqual(dictionary.count, 0)
    }

    func testReserveCapacity() {
        let dictionary = DictionaryHolder<Int, String>([:])

        dictionary.reserveCapacity(10)

        XCTAssertGreaterThanOrEqual(dictionary.capacity, 10)
    }

    func testCount() {
        let dictionary = DictionaryHolder([10: "10", 20: "20"])

        XCTAssertEqual(dictionary.count, 2)

        dictionary[30] = "30"

        XCTAssertEqual(dictionary.count, 3)
    }
    
    func testSubscriptGetWithRelayableValue() {
        let dictionary = DictionaryHolder([10: "10"])
        
        XCTAssertEqual(dictionary[10], "10")
        XCTAssertNil(dictionary[20])
    }
    
    func testSubscriptGetWithSendableValue() {
        let dictionary = DictionaryHolder([10: Holder(10)])
        
        XCTAssertEqual(dictionary[10], Holder(10))
        XCTAssertNil(dictionary[20])
    }
    
    func testSubscriptSetWithRelayableValue() {
        let dictionary = DictionaryHolder([10: "10"])
        
        dictionary[20] = "20"
        
        XCTAssertEqual(dictionary.rawDictionary, [10: "10", 20: "20"])
        
        dictionary[10] = "100"
        
        XCTAssertEqual(dictionary.rawDictionary, [10: "100", 20: "20"])
        
        dictionary[20] = nil
        
        XCTAssertEqual(dictionary.rawDictionary, [10: "100"])
    }
    
    func testSubscriptSetWithSendableValue() {
        let dictionary = DictionaryHolder([10: Holder(10)])
        
        dictionary[20] = Holder(20)
        
        XCTAssertEqual(dictionary.rawDictionary, [10: Holder(10), 20: Holder(20)])
        
        dictionary[10] = Holder(100)
        
        XCTAssertEqual(dictionary.rawDictionary, [10: Holder(100), 20: Holder(20)])
        
        dictionary[20] = nil
        
        XCTAssertEqual(dictionary.rawDictionary, [10: Holder(100)])
    }
    
    func testEventWithRelayableValues() {
        let dictionary = DictionaryHolder([10: "10", 20: "20"])

        var received: [DictionaryHolder<Int, String>.Event] = []

        let observer = dictionary.chain().do { received.append($0) }.sync()

        XCTAssertEqual(received.count, 1)

        if case .fetched(let dictionary) = received[0] {
            XCTAssertEqual(dictionary, [10: "10", 20: "20"])
        } else {
            XCTAssertTrue(false)
        }

        dictionary.insert(key: 100, value: "100")

        XCTAssertEqual(received.count, 2)

        if case .inserted(let key, let value) = received[1] {
            XCTAssertEqual(key, 100)
            XCTAssertEqual(value, "100")
        } else {
            XCTAssertTrue(false)
        }

        dictionary.removeValue(forKey: 20)

        XCTAssertEqual(received.count, 3)

        if case .removed(let key, let value) = received[2] {
            XCTAssertEqual(value, "20")
            XCTAssertEqual(key, 20)
        } else {
            XCTAssertTrue(false)
        }

        XCTAssertEqual(dictionary.rawDictionary, [10: "10", 100: "100"])

        dictionary.replace(key: 100, value: "500")

        XCTAssertEqual(received.count, 4)

        if case .replaced(let key, let value) = received[3] {
            XCTAssertEqual(key, 100)
            XCTAssertEqual(value, "500")
        } else {
            XCTAssertTrue(false)
        }

        XCTAssertEqual(dictionary.rawDictionary, [10: "10", 100: "500"])

        dictionary.set([1000: "1000", 999: "999"])

        XCTAssertEqual(received.count, 5)

        if case .any(let dictionary) = received[4] {
            XCTAssertEqual(dictionary, [1000: "1000", 999: "999"])
        } else {
            XCTAssertTrue(false)
        }

        dictionary.removeAll()

        XCTAssertEqual(received.count, 6)

        if case .any(let dictionary) = received[5] {
            XCTAssertEqual(dictionary, [:])
        } else {
            XCTAssertTrue(false)
        }

        XCTAssertEqual(dictionary.rawDictionary, [:])
        
        observer.invalidate()
    }

    func testEventWithSendableElements() {
        let dictionary = RelayableDictionaryHolder([10: Holder(10), 20: Holder(20)])

        var received: [RelayableDictionaryHolder<Int, Holder<Int>>.Event] = []

        let observer = dictionary.chain().do { received.append($0) }.sync()

        XCTAssertEqual(received.count, 1)

        if case .fetched(let elements) = received[0] {
            XCTAssertEqual(elements, [10: Holder<Int>(10), 20: Holder<Int>(20)])
        } else {
            XCTAssertTrue(false)
        }

        dictionary.insert(key: 100, value: Holder(100))

        XCTAssertEqual(received.count, 2)

        if case .inserted(let key, let value) = received[1] {
            XCTAssertEqual(value, Holder(100))
            XCTAssertEqual(key, 100)
        } else {
            XCTAssertTrue(false)
        }

        XCTAssertEqual(dictionary.rawDictionary, [10: Holder(10), 20: Holder(20), 100: Holder(100)])

        dictionary.removeValue(forKey: 20)

        XCTAssertEqual(received.count, 3)

        if case .removed(let key, let value) = received[2] {
            XCTAssertEqual(value, Holder(20))
            XCTAssertEqual(key, 20)
        } else {
            XCTAssertTrue(false)
        }

        XCTAssertEqual(dictionary.rawDictionary, [10: Holder(10), 100: Holder(100)])

        dictionary[10]?.value = 11

        XCTAssertEqual(received.count, 4)

        if case .relayed(let relayedValue, let key, let value) = received[3] {
            XCTAssertEqual(value, Holder(11))
            XCTAssertEqual(key, 10)
            XCTAssertEqual(relayedValue, 11)
        } else {
            XCTAssertTrue(false)
        }

        XCTAssertEqual(dictionary.rawDictionary, [10: Holder(11), 100: Holder(100)])

        dictionary.replace(key: 100, value: Holder(500))

        XCTAssertEqual(received.count, 5)

        if case .replaced(let key, let value) = received[4] {
            XCTAssertEqual(value, Holder(500))
            XCTAssertEqual(key, 100)
        } else {
            XCTAssertTrue(false)
        }

        XCTAssertEqual(dictionary.rawDictionary, [10: Holder(11), 100: Holder(500)])

        dictionary.set([1000: Holder(1000), 999: Holder(999)])

        XCTAssertEqual(received.count, 6)

        if case .any(let dictionary) = received[5] {
            XCTAssertEqual(dictionary, [1000: Holder(1000), 999: Holder(999)])
        } else {
            XCTAssertTrue(false)
        }

        dictionary.removeAll()

        XCTAssertEqual(received.count, 7)

        if case .any(let dictionary) = received[6] {
            XCTAssertEqual(dictionary, [:])
        } else {
            XCTAssertTrue(false)
        }
        
        observer.invalidate()
    }
    
    func testEventWithSendableElementsBySubscript() {
        let dictionary = RelayableDictionaryHolder([10: Holder(10), 20: Holder(20)])
        
        var received: [RelayableDictionaryHolder<Int, Holder<Int>>.Event] = []
        
        let observer = dictionary.chain().do { received.append($0) }.sync()
        
        XCTAssertEqual(received.count, 1)
        
        if case .fetched(let elements) = received[0] {
            XCTAssertEqual(elements, [10: Holder<Int>(10), 20: Holder<Int>(20)])
        } else {
            XCTAssertTrue(false)
        }
        
        dictionary[100] = Holder(100)
        
        XCTAssertEqual(received.count, 2)
        
        if case .inserted(let key, let value) = received[1] {
            XCTAssertEqual(value, Holder(100))
            XCTAssertEqual(key, 100)
        } else {
            XCTAssertTrue(false)
        }
        
        XCTAssertEqual(dictionary.rawDictionary, [10: Holder(10), 20: Holder(20), 100: Holder(100)])
        
        dictionary[20] = nil
        
        XCTAssertEqual(received.count, 3)
        
        if case .removed(let key, let value) = received[2] {
            XCTAssertEqual(value, Holder(20))
            XCTAssertEqual(key, 20)
        } else {
            XCTAssertTrue(false)
        }
        
        XCTAssertEqual(dictionary.rawDictionary, [10: Holder(10), 100: Holder(100)])
        
        dictionary[10]?.value = 11
        
        XCTAssertEqual(received.count, 4)
        
        if case .relayed(let relayedValue, let key, let value) = received[3] {
            XCTAssertEqual(value, Holder(11))
            XCTAssertEqual(key, 10)
            XCTAssertEqual(relayedValue, 11)
        } else {
            XCTAssertTrue(false)
        }
        
        XCTAssertEqual(dictionary.rawDictionary, [10: Holder(11), 100: Holder(100)])
        
        dictionary[100] = Holder(500)
        
        XCTAssertEqual(received.count, 5)
        
        if case .replaced(let key, let value) = received[4] {
            XCTAssertEqual(value, Holder(500))
            XCTAssertEqual(key, 100)
        } else {
            XCTAssertTrue(false)
        }
        
        XCTAssertEqual(dictionary.rawDictionary, [10: Holder(11), 100: Holder(500)])
        
        dictionary.set([1000: Holder(1000), 999: Holder(999)])
        
        XCTAssertEqual(received.count, 6)
        
        if case .any(let dictionary) = received[5] {
            XCTAssertEqual(dictionary, [1000: Holder(1000), 999: Holder(999)])
        } else {
            XCTAssertTrue(false)
        }
        
        dictionary.removeAll()
        
        XCTAssertEqual(received.count, 7)
        
        if case .any(let dictionary) = received[6] {
            XCTAssertEqual(dictionary, [:])
        } else {
            XCTAssertTrue(false)
        }
        
        observer.invalidate()
    }
}
