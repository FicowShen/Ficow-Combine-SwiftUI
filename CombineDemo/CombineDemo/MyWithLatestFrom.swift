import Foundation
import Combine

extension Publisher {
    func myWithLatestFrom<Other: Publisher, Result>(_ other: Other, transform: @escaping (Output, Other.Output) -> Result) -> Publishers.MyWithLatestFrom<Self, Other, Result> {
        return Publishers.MyWithLatestFrom(upstream: self,
                                           second: other,
                                           transform: transform)
    }
}

extension Publishers {
    struct MyWithLatestFrom<Upstream: Publisher, Other: Publisher, Output>: Publisher {

        typealias Failure = Upstream.Failure

        public typealias Transform = (Upstream.Output, Other.Output) -> Output

        private let upstream: Upstream
        private let second: Other
        private let transform: Transform

        init(upstream: Upstream, second: Other, transform: @escaping Transform) {
            self.upstream = upstream
            self.second = second
            self.transform = transform
        }

        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            subscriber.receive(subscription: Subscription(upstream: upstream,
                                                          downstream: subscriber,
                                                          second: second,
                                                          transform: transform))
        }

    }
}

extension Publishers.MyWithLatestFrom {
    final class Subscription<Downstream: Subscriber>: Combine.Subscription where Downstream.Input == Output, Downstream.Failure == Failure {

        private let upstream: Upstream
        private let second: Other
        private let downstream: Downstream
        private let transform: Transform

        init(upstream: Upstream,
             downstream: Downstream,
             second: Other,
             transform: @escaping Transform) {
            self.upstream = upstream
            self.second = second
            self.downstream = downstream
            self.transform = transform

            trackLatestFromSecondStream()
        }

        func request(_ demand: Subscribers.Demand) {

        }

        func cancel() {

        }

        private func trackLatestFromSecondStream() {

        }
    }
}
