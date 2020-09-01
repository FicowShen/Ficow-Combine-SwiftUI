//
//  MyMap.swift
//  CombineDemo
//
//  Created by Ficow on 2020/9/2.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import Foundation
import Combine

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
            upstream
                .compactMap(self.resultSelector)
                .receive(subscriber: subscriber)
        }

    }
}
