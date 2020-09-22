import Foundation
import Combine

extension Publisher {

    func bind<Output, Failure: Error>(to subscriber: AnySubscriber<Output, Failure>) -> AnyCancellable where Output == Self.Output, Failure == Self.Failure  {
        return sink(receiveCompletion: { completion in
            subscriber.receive(completion: completion)
        }, receiveValue: { value in
            _ = subscriber.receive(value)
        })
    }

    func mapToVoid() -> Publishers.Map<Self, Void> {
        return map { _ in () }
    }

    func withLatestFrom<Other: Publisher, Result>(_ other: Other, transform: @escaping ((Output, Other.Output) -> Result)) -> Publishers.MyWithLatestFrom<Self, Other, Result> {
        return Publishers.MyWithLatestFrom(upstream: self,
                                           second: other,
                                           transform: transform)
    }

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

        func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
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
        
        private var initialDemandOfDownstream = Subscribers.Demand.none
        
        private var otherSubscription: Combine.Subscription?
        private var latestValueFromOther: Other.Output?

        private var backPressureSubscriber: BackPressureSubscriber<Upstream, Downstream>?

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
            guard latestValueFromOther != nil else {
                initialDemandOfDownstream += demand
                return
            }
            backPressureSubscriber?.requestDemand(demand)
        }

        func cancel() {
            otherSubscription?.cancel()
            backPressureSubscriber = nil
        }

        private func trackLatestFromSecondStream() {
            var isTrackingMainUpstream = false
            let subcriber = AnySubscriber<Other.Output, Other.Failure>(
                receiveSubscription: { [weak self] (subscription) in
                    self?.otherSubscription = subscription
                    subscription.request(.unlimited)
                },
                receiveValue: { [weak self] (value) -> Subscribers.Demand in
                    self?.latestValueFromOther = value
                    
                    if !isTrackingMainUpstream {
                        isTrackingMainUpstream = true
                        self?.trackMainUpstream()
                    }
                    
                    return .unlimited
                },
                receiveCompletion: { (completion) in
                    
                })
            second.subscribe(subcriber)
        }
        
        private func trackMainUpstream() {
            backPressureSubscriber = BackPressureSubscriber(upstream: upstream,
                                                            downstream: downstream,
                                                            transformOutput: { [weak self] value in
                                                                guard let self = self,
                                                                    let other = self.latestValueFromOther
                                                                    else { return nil }
                                                                return self.transform(value, other) },
                                                            transformFailure: { $0 })
            request(initialDemandOfDownstream)
            initialDemandOfDownstream = .none
        }
    }
}
