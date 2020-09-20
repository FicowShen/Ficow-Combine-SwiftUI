import Foundation
import Combine

final class CombineSchedulersDemo {

    private var cancellables = Set<AnyCancellable>()

    func run() {
//        receiveOn()
//        subscribeOn()
        subscribeOn2()
    }

    private func receiveOn() {
        let queue = DispatchQueue(label: "my_queue")
        let queueKey = DispatchSpecificKey<String>()
        queue.setSpecific(key: queueKey, value: queue.label)

        DispatchQueue.main.setSpecific(key: queueKey, value: DispatchQueue.main.label)

        queue.async {
            Future<Int, Never> { promise in
                print("Future queue:", DispatchQueue.getSpecific(key: queueKey) ?? "")
                promise(.success(1))
            }
            .map { value -> Int in
                print("map queue:", DispatchQueue.getSpecific(key: queueKey) ?? "")
                return value
            }
            .receive(on: DispatchQueue.main)
            .sink { value in
                print("sink queue:", DispatchQueue.getSpecific(key: queueKey) ?? "")
            }
            .store(in: &self.cancellables)
        }

        func commonUsage() {
            Future<Int, Never> { promise in
                DispatchQueue.global().async {
                    // 耗时的后台任务
                    // ...
                    let result = 1
                    promise(.success(result))
                }
            }
            .receive(on: DispatchQueue.main) // 切换到主线程
            .sink { value in
                // 在主线程处理耗时任务得到的结果
            }
            .store(in: &self.cancellables)
        }
    }

    private func subscribeOn() {
        let queue = DispatchQueue(label: "my_queue")
        let queueKey = DispatchSpecificKey<String>()
        queue.setSpecific(key: queueKey, value: queue.label)

        DispatchQueue.main.setSpecific(key: queueKey, value: DispatchQueue.main.label)

        queue.async {
            Future<Int, Never> { promise in
                print("Future queue:", DispatchQueue.getSpecific(key: queueKey) ?? "")
                promise(.success(1))
            }
            .map { value -> Int in
                print("map queue:", DispatchQueue.getSpecific(key: queueKey) ?? "")
                return value
            }
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { value in
                print("sink queue:", DispatchQueue.getSpecific(key: queueKey) ?? "")
            }
            .store(in: &self.cancellables)
        }
    }

    private func subscribeOn2() {
        let queue = DispatchQueue(label: "my_queue")
        let queueKey = DispatchSpecificKey<String>()
        queue.setSpecific(key: queueKey, value: queue.label)

        DispatchQueue.main.setSpecific(key: queueKey, value: DispatchQueue.main.label)

        queue.async {
            Deferred<Future<Int, Never>> {
                print("Deferred queue:", DispatchQueue.getSpecific(key: queueKey) ?? "")
                return Future<Int, Never> { promise in
                    print("Future queue:", DispatchQueue.getSpecific(key: queueKey) ?? "")
                    promise(.success(1))
                }
            }
            .map { value -> Int in
                print("map queue:", DispatchQueue.getSpecific(key: queueKey) ?? "")
                return value
            }
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { value in
                print("sink queue:", DispatchQueue.getSpecific(key: queueKey) ?? "")
            }
            .store(in: &self.cancellables)
        }
    }
}
