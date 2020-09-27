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

        // 让自身的失败类型和上游保持一致
        typealias Failure = Upstream.Failure

        private let upstream: Upstream
        private let transform: (Upstream.Output) -> Output

        init(upstream: Upstream, transform: @escaping (Upstream.Output) -> Output) {
            // 引用上游发布者，在订阅后绑定下游和上游
            self.upstream = upstream
            self.transform = transform
        }

        /// 下游执行订阅操作时会调用这个方法，传入的参数就是下游订阅者
        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {

            upstream
                // 执行转换操作
                .map(self.transform)
                // 让下游订阅自身
                .receive(subscriber: subscriber)
        }
    }
}
