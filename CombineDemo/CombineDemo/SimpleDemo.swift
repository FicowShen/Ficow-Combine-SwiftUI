//
//  SimpleDemo.swift
//  CombineDemo
//
//  Created by FicowShen on 2020/6/24.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import UIKit
import Combine

// https://www.swiftbysundell.com/basics/combine/?utm_campaign=iOS%2BDev%2BWeekly&utm_medium=email&utm_source=iOS%2BDev%2BWeekly%2BIssue%2B452
final class SimpleDemo {

    class SimplestDemo {

        var cancellable: AnyCancellable?

        func makeRequest() {
            let url = URL(string: "https://ficow.cn")!
            let dataTaskPublisher = URLSession.shared.dataTaskPublisher(for: url)

            cancellable = dataTaskPublisher
                .delay(for: .seconds(2), scheduler: DispatchQueue.global())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    // 发布结束的时候会被调用一次
                    switch completion {
                    case .failure(let error):
                        print(error)
                    case .finished:
                        print("success")
                    }
                }, receiveValue: { value in
                    // 每次接收到发布者发送的值都会被调用一次
                    // 因为发起的是网络请求，所以这里只会被调用一次
                    print(value.data)
                    print(value.response)
                })
        }

    }

    class OfficialDemo {

        class MyViewModel {
            var filterString = ""
        }

        private let filterField = UITextField()
        private let myViewModel = MyViewModel()
        private var subscription: AnyCancellable?

        func bind() {
            subscription = NotificationCenter.default
                .publisher(for: UITextField.textDidChangeNotification, object: filterField)
                .map( { (($0.object as! UITextField).text ?? "") } )
                .filter( { $0.unicodeScalars.allSatisfy({CharacterSet.alphanumerics.contains($0)}) } )
                .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
                .receive(on: RunLoop.main)
                .assign(to:\MyViewModel.filterString, on: myViewModel)
        }
    }

    struct Repository: Codable {
        var name: String
        var url: URL
    }
    
    class Counter {
        var publisher: AnyPublisher<Int, Never> {
            // Here we're "erasing" the information of which type
            // that our subject actually is, only letting our outside
            // code know that it's a read-only publisher:
            subject.eraseToAnyPublisher()
        }
        
        private(set) var value = 0 {
            didSet { subject.send(value) }
        }
        
        // By storing our subject in a private property, we'll only
        // be able to send new values to it from within this class:
        private let subject = PassthroughSubject<Int, Never>()
        
        func increment() {
            value += 1
        }
    }
    
    var cancellable: AnyCancellable?
    var cancellable2: AnyCancellable?
    let demo = SimplestDemo()
    func run() {
        demo.makeRequest()
//        dataTaskDemo()
//        counterDemo()
    }
    
    func dataTaskDemo() {
        let url = URL(string: "https://api.github.com/repos/johnsundell/publish")!
        let publisher = URLSession.shared.dataTaskPublisher(for: url)
        
        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                // Called once, when the publisher was completed.
                log(completion)
                switch completion {
                case .failure(let error):
                    log(error)
                case .finished:
                    log("Success")
                }
        },
            receiveValue: { value in
                // Can be called multiple times, each time that a
                // new value was emitted by the publisher.
                log(value)
                let decoder = JSONDecoder()
                do {
                    // Since each value passed into our closure will be a tuple
                    // containing the downloaded data, as well as the network
                    // response itself, we're accessing the 'data' property here:
                    let repo = try decoder.decode(Repository.self, from: value.data)
                    log(repo)
                } catch {
                    log(error)
                }
        })
        // cancellable.cancel()
        
        // without reference of self.cancellable, the subscription will get released when the cancellable is deallocated
        // self.cancellable = cancellable
        
        
        let cancellable2 = publisher.map(\.data) // map with swift keypath
            .decode(
                type: Repository.self,
                decoder: JSONDecoder()
        ).eraseToAnyPublisher()
            .receive(on: DispatchQueue.main) // main thread
            .sink(
                receiveCompletion: { completion in
                    // Called once, when the publisher was completed.
                    log(completion)
                    switch completion {
                    case .failure(let error):
                        log(error)
                    case .finished:
                        log("Success")
                    }
            },receiveValue: { value in
                // Can be called multiple times, each time that a
                // new value was emitted by the publisher.
                log(value) // mapped Repository object
            })
        self.cancellable2 = cancellable2
    }
    
    func counterDemo() {
        let counter = Counter()
        let cancellable3 = counter.publisher
            .filter { $0 > 2 }
            .sink { value in
                log(value)
        }
        
        // Since we're filtering out all values below 3, only our final
        // increment call will result in a value being printed:
        counter.increment()
        counter.increment()
        counter.increment()
        
        // counter.publisher.send(17) // cannot access `send` because of `eraseToAnyPublisher`
        cancellable3.cancel()
    }
}
