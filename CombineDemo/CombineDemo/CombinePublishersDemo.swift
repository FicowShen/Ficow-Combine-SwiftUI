import Foundation
import Combine

final class CombinePublishersDemo {

    private var cancellables = Set<AnyCancellable>()

    func run() {
//        just()
//        just2()
//        future()
//        future2()
//        deferred()
        empty()
//        sequence()
    }

    private func just() {
        Just(1) // 直接发送1
            .sink { value in
                // 输出：just() 1
                print(#function, value)
            }
            .store(in: &cancellables)
    }

    private func just2() {
        // 使用 Fail 发送失败
        Fail(error: NSError(domain: "", code: 0, userInfo: nil))
            .catch { _ in
                // 捕获错误，返回 Just(3)
                return Just(3)
            }
            .sink { value in
                // 输出：just2() 3
                print(#function, value)
            }
            .store(in: &cancellables)
    }

    private func future() {
        Future<Int, Never> { promise in
            // 延时1秒
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                promise(.success(2))
            }
        }
        .sink { value in
            // 输出：future() 2
            print(#function, value)
        }
        .store(in: &cancellables)
    }

    private func bigTask() -> Future<Int, Error> {
        return Future() { promise in
            // 模拟耗时操作
            sleep(1)
            guard Bool.random() else {
                promise(.failure(NSError(domain: "com.ficowshen.blog", code: -1, userInfo: [NSLocalizedDescriptionKey: "task failed"])))
                return
            }
            promise(.success(3))
        }
    }

    private func future2() {
        bigTask()
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    // 输出：future2() finished
                    print(#function, "finished")
                case .failure(let error):
                    // 输出：future2() Error Domain=com.ficowshen.blog Code=-1 "task failed" UserInfo={NSLocalizedDescription=task failed}
                    print(#function, error)
                }
            }, receiveValue: { value in
                // 输出：future2() 3
                print(#function, value)
            })
            .store(in: &cancellables)
    }

    private func deferred() {
        let deferredPublisher = Deferred<AnyPublisher<Bool, Error>> {
            // 在订阅之后才会执行
            print(Date(), "Future inside Deferred created")
            return Future<Bool, Error> { promise in
                promise(.success(true))
            }.eraseToAnyPublisher()
        }.eraseToAnyPublisher()

        print(Date(), "Deferred created")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // 延迟1秒后进行订阅
            deferredPublisher
                .sink(receiveCompletion: { completion in
                    print(Date(), "Deferred receiveCompletion:", completion)
                }, receiveValue: { value in
                    print(Date(), "Deferred receiveValue:", value)
                })
                .store(in: &self.cancellables)
        }
    }

    private func empty() {
        Empty<Never, Error>() // 或者 Empty<Never, Error>(completeImmediately: true)
            .sink(receiveCompletion: { completion in
                // 输出：empty() finished
                print(#function, completion)
            }, receiveValue: { _ in

            })
            .store(in: &self.cancellables)
    }

    private func sequence() {
        [1, 2, 3].publisher
            .sink(receiveCompletion: { completion in
                // 输出：sequence() finished
                print(#function, completion)
            }, receiveValue: { value in
                // 输出：sequence() 1
                // 输出：sequence() 2
                // 输出：sequence() 3
                print(#function, value)
            })
            .store(in: &self.cancellables)
    }
}
