//
//  TestCustomOperatorTests.swift
//  CombineDemoTests
//
//  Created by FicowShen on 2020/9/1.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import XCTest
import Combine

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
    
}

extension Publisher {
    func myMap1<Result>(resultSelector: @escaping (Output) -> Result) -> Publishers.Map<Self, Result> {
        return Publishers.Map(upstream: self, transform: resultSelector)
    }
    
    func myMap2<Result>(resultSelector: @escaping (Output) -> Result) -> Publishers.MyMap<Self, Result> {
        return Publishers.MyMap(upstream: self, resultSelector: resultSelector)
    }
}

extension Publishers {
    struct MyMap<Upstream: Publisher, Output>: Publisher {
        
        typealias Failure = Upstream.Failure
        public typealias ResultSelector = (Upstream.Output) -> Output
        
        let upstream: Upstream
        let resultSelector: (Upstream.Output) -> Output
        
        init(upstream: Upstream, resultSelector: @escaping ResultSelector) {
            self.upstream = upstream
            self.resultSelector = resultSelector
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            subscriber.receive(subscription: Subscription(upstream: upstream,
                                                          downstream: subscriber,
                                                          resultSelector: resultSelector))
        }
        
    }
}

extension Publishers.MyMap {
    class Subscription<Downstream: Subscriber>: Combine.Subscription where Downstream.Input == Output, Downstream.Failure == Failure {
        
        let upstream: Upstream
        let downstream: Downstream
        let resultSelector: ResultSelector
        
        init(upstream: Upstream, downstream: Downstream, resultSelector: @escaping ResultSelector) {
            self.upstream = upstream
            self.downstream = downstream
            self.resultSelector = resultSelector
        }
        
        func request(_ demand: Subscribers.Demand) {
//            upstream.subscribe(self)
        }
        
        func cancel() {
            
        }
        
    }
}
