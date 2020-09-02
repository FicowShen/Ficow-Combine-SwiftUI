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
        
        let subject1 = PassthroughSubject<Int, Never>()
        let subject2 = PassthroughSubject<String, Never>()
        
        subject1
            .myWithLatestFrom(subject2, transform: { (intValue, stringValue) -> String in
                if stringValue == "2" {
                    return "22"
                }
                return "33"
            })
            .sink { v in
                XCTAssertEqual(v, "33")
                expect.fulfill()
            }
            .store(in: &cancellables)
        
        subject2.send("2")
        subject2.send("3")
        subject1.send(1)
        
        wait(for: [expect], timeout: 5)
    }
    
}
