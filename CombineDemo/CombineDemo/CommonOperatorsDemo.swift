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
        mergeDemo()
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

}

fileprivate extension CommonOperatorsDemo {
    
    struct Model: Decodable {
        let id: Int
    }
}
