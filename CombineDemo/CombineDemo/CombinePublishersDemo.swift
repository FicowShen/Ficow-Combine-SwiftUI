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
//        empty()
//        sequence()
//        fail()
//        record()
//        withoutShare()
//        withShare()
//        withShareAndConnectable()
//        multicast()
//        observableObject()
//        published()
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
        
        ["key1": "value1",
         "key2": "value2",
         "key3": "value3"].publisher
            .sink(receiveCompletion: { completion in
                // 输出：sequence() finished
                print(#function, completion)
            }, receiveValue: { value in
                // 输出：sequence() (key: "key2", value: "value2")
                // 输出：sequence() (key: "key3", value: "value3")
                // 输出：sequence() (key: "key1", value: "value1")
                print(#function, value)
            })
            .store(in: &self.cancellables)
    }
    
    private func fail() {
        Fail<Never, NSError>(error: NSError(domain: "", code: 0, userInfo: nil))
            .sink(receiveCompletion: { completion in
                // 输出：fail() failure(Error Domain= Code=0 "(null)")
                print(#function, completion)
            }, receiveValue: { _ in
                
            })
            .store(in: &cancellables)
    }
    
    private func record() {
        Record<Int, Never> { record in
            record.receive(1)
            record.receive(2)
            record.receive(3)
            record.receive(completion: .finished)
        }
        .sink(receiveCompletion: { completion in
            // 输出：record() finished
            print(#function, completion)
        }, receiveValue: { value in
            // 输出：record() 1
            // 输出：record() 2
            // 输出：record() 3
            print(#function, value)
        })
        .store(in: &cancellables)
    }
    
    private func withoutShare() {
        let deferred = Deferred<Future<Int, Never>> {
            print("creating Future")
            return Future<Int, Never> { promise in
                print("promise(.success(1))")
                promise(.success(1))
            }
        }
        
        deferred
            .print("1_")
            .sink(receiveCompletion: { completion in
                print("receiveCompletion1", completion)
            }, receiveValue: { value in
                print("receiveValue1", value)
            })
            .store(in: &cancellables)
        
        deferred
            .print("2_")
            .sink(receiveCompletion: { completion in
                print("receiveCompletion2", completion)
            }, receiveValue: { value in
                print("receiveValue2", value)
            })
            .store(in: &cancellables)
    }
    
    private func withShare() {
        let deferred = Deferred<Future<Int, Never>> {
            print("creating Future")
            return Future<Int, Never> { promise in
                print("promise(.success(1))")
                promise(.success(1))
            }
        }
        
        let sharedPublisher = deferred
            .print("0_")
            .share()
        
        sharedPublisher
            .print("1_")
            .sink(receiveCompletion: { completion in
                print("receiveCompletion1", completion)
            }, receiveValue: { value in
                print("receiveValue1", value)
            })
            .store(in: &cancellables)
        
        sharedPublisher
            .print("2_")
            .sink(receiveCompletion: { completion in
                print("receiveCompletion2", completion)
            }, receiveValue: { value in
                print("receiveValue2", value)
            })
            .store(in: &cancellables)
    }
    
    private func withShareAndConnectable() {
        let deferred = Deferred<Future<Int, Never>> {
            print("creating Future")
            return Future<Int, Never> { promise in
                print("promise(.success(1))")
                promise(.success(1))
            }
        }
        
        let sharedPublisher = deferred
            .print("0_")
            .share()
            .makeConnectable() // 自行决定发布者何时开始发送订阅元素给订阅者
        
        sharedPublisher
            .print("1_")
            .sink(receiveCompletion: { completion in
                print("receiveCompletion1", completion)
            }, receiveValue: { value in
                print("receiveValue1", value)
            })
            .store(in: &cancellables)
        
        sharedPublisher
            .print("2_")
            .sink(receiveCompletion: { completion in
                print("receiveCompletion2", completion)
            }, receiveValue: { value in
                print("receiveValue2", value)
            })
            .store(in: &cancellables)
        
        sharedPublisher
            .connect() // 让发布者开始发送内容
            .store(in: &cancellables)
    }
    
    private func multicast() {
        let multicastSubject = PassthroughSubject<Int, Never>()
        let deferred = Deferred<Future<Int, Never>> {
            print("creating Future")
            return Future<Int, Never> { promise in
                print("promise(.success(1))")
                promise(.success(1))
            }
        }
        
        let sharedPublisher = deferred
            .print("0_")
            .multicast(subject: multicastSubject)
            
        sharedPublisher
            .print("1_")
            .sink(receiveCompletion: { completion in
                print("receiveCompletion1", completion)
            }, receiveValue: { value in
                print("receiveValue1", value)
            })
            .store(in: &cancellables)
        
        sharedPublisher
            .print("2_")
            .sink(receiveCompletion: { completion in
                print("receiveCompletion2", completion)
            }, receiveValue: { value in
                print("receiveValue2", value)
            })
            .store(in: &cancellables)
        
        sharedPublisher
            .connect()
            .store(in: &cancellables)
    }
    
    private func observableObject() {
        let john = Contact(name: "John Appleseed", age: 24)
        john.objectWillChange
            .sink { _ in
                print("\(john.age) will change")
            }
            .store(in: &cancellables)
        print(john.haveBirthday())
        // Prints "24 will change"
        // Prints "25"
    }
    
    private func published() {
        let weather = Weather(temperature: 20)
        weather
            .$temperature // 请注意这里的 $ 符号，通过 $ 操作符来访问发布者
            .sink() { value in
                print("Temperature before: \(weather.temperature)") // 属性中的值尚未改变
                print("Temperature now: \(value)") // 发布者发布的是新值
            }
            .store(in: &cancellables)
        weather.temperature = 25 // 请注意这里没有 $ 符号，访问的是被属性包装器包装起来的值
        // Prints:
        // Temperature before: 20.0
        // Temperature now: 20.0
        // Temperature before: 20.0
        // Temperature now: 25.0
    }
}

// refer from: https://developer.apple.com/documentation/combine/observableobject
class Contact: ObservableObject {
    @Published var name: String
    @Published var age: Int


    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }


    func haveBirthday() -> Int {
        age += 1
        return age
    }
}

// refer from: https://developer.apple.com/documentation/combine/published
class Weather {
    @Published var temperature: Double
    init(temperature: Double) {
        self.temperature = temperature
    }
}
