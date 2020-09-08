import Foundation
import Combine

final class CombinePublishersDemo {

    private var cancellables = Set<AnyCancellable>()

    func run() {
        just()
        future()
        future2()
    }

    private func just() {
        Just(1) // 直接发送1
            .sink { value in
                // 输出：just() 1
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

    private func future2() {
        func doSomething() -> Future<Int, Error> {
            return Future() { promise in
                // 模拟耗时操作
                sleep(1)
                promise(.success(3))
            }
        }

        doSomething()
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    // 输出：future2() finished
                    print(#function, "finished")
                case .failure(let error):
                    print(#function, error)
                }
            }, receiveValue: { value in
                // 输出：future2() 3
                print(#function, value)
            })
            .store(in: &cancellables)
    }
}
