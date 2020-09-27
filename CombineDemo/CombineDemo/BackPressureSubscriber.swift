import Foundation
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class BackPressureSubscriber<Upstream: Publisher, Downstream: Subscriber>: Subscriber {

    typealias TransformFailure = (Upstream.Failure) -> Downstream.Failure
    typealias TransformOutput = (Upstream.Output) -> Downstream.Input?

    private let upstream: Upstream
    private let downstream: Downstream

    private let transformOutput: TransformOutput
    private let transformFailure: TransformFailure

    private var subscription: Subscription?

    init(upstream: Upstream,
         downstream: Downstream,
         transformOutput: @escaping TransformOutput,
         transformFailure: @escaping TransformFailure) {
        self.upstream = upstream
        self.downstream = downstream
        self.transformOutput = transformOutput
        self.transformFailure = transformFailure
        // 创建时就订阅上游
        upstream.subscribe(self)
    }

    deinit {
        // 销毁时，自动取消订阅
        cancelSubscription()
    }

    func requestDemand(_ demand: Subscribers.Demand) {
        guard demand > .none else { return }
        subscription?.request(demand)
    }

    func cancelSubscription() {
        subscription?.cancel()
        subscription = nil
    }

    func receive(subscription: Subscription) {
        self.subscription = subscription
    }

    func receive(_ input: Upstream.Output) -> Subscribers.Demand {
        guard let transformedInput = transformOutput(input) else {
            return .none
        }
        return downstream.receive(transformedInput)
    }

    func receive(completion: Subscribers.Completion<Upstream.Failure>) {
        switch completion {
        case .finished:
            downstream.receive(completion: .finished)
        case .failure(let error):
            downstream.receive(completion: .failure(transformFailure(error)))
        }
        cancelSubscription()
    }
}

extension BackPressureSubscriber: Cancellable {
    func cancel() {
        receive(completion: .finished)
    }
}
