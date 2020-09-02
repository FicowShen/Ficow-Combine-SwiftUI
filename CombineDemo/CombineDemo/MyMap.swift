import Foundation
import Combine

extension Publisher {
    func myMap1<Result>(transform: @escaping (Output) -> Result) -> Publishers.Map<Self, Result> {
        return Publishers.Map(upstream: self, transform: transform)
    }

    func myMap2<Result>(transform: @escaping (Output) -> Result) -> Publishers.MyMap<Self, Result> {
        return Publishers.MyMap(upstream: self, transform: transform)
    }
}

extension Publishers {
    struct MyMap<Upstream: Publisher, Output>: Publisher {

        typealias Failure = Upstream.Failure

        private let upstream: Upstream
        private let transform: (Upstream.Output) -> Output

        init(upstream: Upstream, transform: @escaping (Upstream.Output) -> Output) {
            self.upstream = upstream
            self.transform = transform
        }

        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            upstream
                .compactMap(self.transform)
                .receive(subscriber: subscriber)
        }
    }
    
}
