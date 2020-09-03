//
//  TestCustomOperatorTests.swift
//  CombineDemoTests
//
//  Created by FicowShen on 2020/9/1.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import XCTest
import Combine

@testable import CombineDemo

final class TestCustomOperatorTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        cancellables = Set<AnyCancellable>()
    }
    
    func testMyMap1() throws {
        let expect = expectation(description: #function)
        
        Just(1)
            .myMap1 { $0.description }
            .sink { v in
                XCTAssertEqual(v, "1")
                expect.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expect], timeout: 5)
    }

    func testMyMap2() throws {
        let expect = expectation(description: #function)
        
        Just(1)
            .myMap2 { $0.description }
            .sink { v in
                XCTAssertEqual(v, "1")
                expect.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expect], timeout: 5)
    }
    
    func testMyWithLatestFrom() throws {
        let expect = expectation(description: #function)
        expect.expectedFulfillmentCount = 4
        
        let subject1 = PassthroughSubject<Int, Never>()
        let subject2 = PassthroughSubject<String, Never>()
        
        var results = [String]()
        
        subject1
            .myWithLatestFrom(subject2, transform: { (intValue, stringValue) -> String in
                return intValue.description + stringValue
            })
            .sink { v in
                results.append(v)
                expect.fulfill()
            }
            .store(in: &cancellables)
        
        subject2.send("2")
        subject2.send("3")
        subject1.send(1)
        subject2.send("4")
        subject1.send(5)
        subject1.send(6)
        subject2.send("7")
        subject2.send("8")
        subject1.send(9)
        
        wait(for: [expect], timeout: 3)
        XCTAssertEqual(["13", "54", "64", "98"], results)
    }
    
}
