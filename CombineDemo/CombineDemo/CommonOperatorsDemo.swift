//
//  CommonOperators.swift
//  CombineDemo
//
//  Created by FicowShen on 2020/9/13.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import Foundation
import Combine

final class CommonOperatorsDemo {
    
    private var cancellables = Set<AnyCancellable>()
    
    func run() {
//        printDemo()
//        breakpointDemo()
//        handleEventsDemo()
//        mapDemo()
//        flatMapDemo()
//        mergeDemo()
//        combineLatestDemo()
//        zipDemo()
//        setFailureTypeDemo()
//        switchToLatestDemo()
        switchToLatestDemo2()
    }
    
    private func printDemo() {
        [1, 2].publisher
            .print("_")
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    private func breakpointDemo() {
        [1, 2].publisher
            .breakpoint(receiveSubscription: { subscription in
                return false // 返回 true 以抛出 SIGTRAP 中断信号，调试器会被调起
            }, receiveOutput: { value in
                return true // 返回 true 以抛出 SIGTRAP 中断信号，调试器会被调起
            }, receiveCompletion: { completion in
                return false // 返回 true 以抛出 SIGTRAP 中断信号，调试器会被调起
            })
            .sink(receiveValue: { _ in
                
            })
            .store(in: &cancellables)
    }
    
    private func handleEventsDemo() {
        [1, 2].publisher
            .handleEvents(receiveSubscription: { subscription in
                // 订阅事件
            }, receiveOutput: { value in
                // 值事件
            }, receiveCompletion: { completion in
                // 完成事件
            }, receiveCancel: {
                // 取消事件
            }, receiveRequest: { demand in
                // 请求需求的事件
            })
            .sink(receiveValue: { _ in
                
            })
            .store(in: &cancellables)
    }
    
    private func mapDemo() {
        [1, 2].publisher
            .map { $0.description + $0.description }
            .sink(receiveValue: { value in
                print(value)
            })
            .store(in: &cancellables)
    }
    
    private func flatMapDemo() {
        guard let data1 = #"{"id": 1}"#.data(using: .utf8),
            let data2 = #"{"i": 2}"#.data(using: .utf8),
            let data3 = #"{"id": 3}"#.data(using: .utf8)
            else { fatalError() }
        
        [data1, data2, data3].publisher
            .flatMap { data -> AnyPublisher<Model?, Never> in
                return Just(data)
                    .decode(type: Model?.self, decoder: JSONDecoder())
                    .catch {_ in
                        // 解析失败时，返回默认值 nil
                        return Just(nil)
                    }.eraseToAnyPublisher()
            }
            .sink(receiveValue: { value in
                print(value)
            })
            .store(in: &cancellables)
        
        [data1, data2, data3].publisher
            .setFailureType(to: Error.self)
            .flatMap { data -> AnyPublisher<Model?, Error> in
                return Just(data)
                    .decode(type: Model?.self, decoder: JSONDecoder())
                    .eraseToAnyPublisher()
            }
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { value in
                print(value)
            })
            .store(in: &cancellables)
    }
    
    private func mergeDemo() {
        let oddPublisher = PassthroughSubject<Int, Never>()
        let evenPublisher = PassthroughSubject<Int, Never>()
        
        oddPublisher
            .merge(with: evenPublisher)
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { value in
                print(value)
            })
            .store(in: &cancellables)
        
        oddPublisher.send(1)
        evenPublisher.send(2)
        oddPublisher.send(3)
        evenPublisher.send(4)
    }
    
    private func combineLatestDemo() {
        let oddPublisher = PassthroughSubject<Int, Never>()
        let evenStringPublisher = PassthroughSubject<String, Never>()
        
        oddPublisher
            .combineLatest(evenStringPublisher)
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { value in
                print(value)
            })
            .store(in: &cancellables)
        
        oddPublisher.send(1)
        evenStringPublisher.send("2")
        oddPublisher.send(3)
        evenStringPublisher.send("4")
    }
    
    private func zipDemo() {
        let oddPublisher = PassthroughSubject<Int, Never>()
        let evenStringPublisher = PassthroughSubject<String, Never>()
        
        oddPublisher
            .zip(evenStringPublisher)
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { value in
                print(value)
            })
            .store(in: &cancellables)
        
        oddPublisher.send(1)
        evenStringPublisher.send("2")
        oddPublisher.send(3)
        evenStringPublisher.send("4")
        evenStringPublisher.send("6")
        evenStringPublisher.send("8")
    }

    private func setFailureTypeDemo() {
        let publisher = PassthroughSubject<Int, Error>()
        
        Just(2)
            .setFailureType(to: Error.self)
            .merge(with: publisher)
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { value in
                print(value)
            })
            .store(in: &cancellables)
        
        publisher.send(1)
    }
    
    private func switchToLatestDemo() {
        let subjects = PassthroughSubject<PassthroughSubject<String, Never>, Never>()
        
        subjects
            .switchToLatest()
            .sink(receiveValue: { print($0) })
            .store(in: &cancellables)
        
        let stringSubject1 = PassthroughSubject<String, Never>()
        
        subjects.send(stringSubject1)
        stringSubject1.send("A")
        
        let stringSubject2 = PassthroughSubject<String, Never>()
        
        subjects.send(stringSubject2) // 发布者切换为 stringSubject2
        
        stringSubject1.send("B") // 下游不会收到
        stringSubject1.send("C") // 下游不会收到
        
        stringSubject2.send("D")
        stringSubject2.send("E")
        
        stringSubject2.send(completion: .finished)
    }
    
    private func switchToLatestDemo2() {
        let subject = PassthroughSubject<String, Error>()
        
        subject.map { value in
            // 在这里发起网络请求，或者其他可能失败的任务
            return Future<Int, Error> { promise in
                if let intValue = Int(value) {
                    // 根据传入的值来延迟执行
                    DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(intValue)) {
                        print(#function, intValue)
                        promise(.success(intValue))
                    }
                } else {
                    // 失败就立刻完成
                    promise(.failure(Errors.notInteger))
                }
            }
            .replaceError(with: 0) // 提供默认值，防止下游的订阅因为失败而被终止
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
        .switchToLatest()
        .sink(receiveCompletion: { completion in
            print(completion)
        }, receiveValue: { value in
            print(value)
        })
        .store(in: &cancellables)
        
        subject.send("3") // 下游不会收到 3
        subject.send("") // 立即失败，下游会收到0
        subject.send("1") // 延时 1 秒后，下游收到 1
    }
}

fileprivate extension CommonOperatorsDemo {
    
    struct Model: Decodable {
        let id: Int
    }
    
    enum Errors: Error {
        case notInteger
    }
}
