//
//  DynamicSayHelloViewModel.swift
//  CombineDemo
//
//  Created by Ficow on 2020/9/21.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import Foundation
import Combine

final class DynamicSayHelloViewModel: DynamicViewModel {
    let input: Input
    let output: Output

    struct Input {
        let name: AnySubscriber<String, Never>
        let validate: AnySubscriber<Void, Never>
    }

    struct Output {
        let greeting: AnyPublisher<String?, Never>
    }

    private let nameSubject = CurrentValueSubject<String, Never>("")
    private let validateSubject = PassthroughSubject<Void, Never>()

    var cancellables = Set<AnyCancellable>()

    init() {
        let greeting = validateSubject
            .withLatestFrom(nameSubject) { (_, name) in
                return name
            }
            .map { name -> String? in
                return "Hello \(name)!"
            }
            .eraseToAnyPublisher()

        // AnyPublisher 可以帮助隐藏内部的实现细节
        self.output = Output(greeting: greeting)

        let nameSink = Subscribers.Sink<String, Never>.init(receiveCompletion: { [unowned nameSubject] completion in
            nameSubject.send(completion: completion)
        }, receiveValue: { [unowned nameSubject] value in
            nameSubject.send(value)
        })
        let validateSink = Subscribers.Sink<Void, Never>.init(receiveCompletion: { [unowned validateSubject] completion in
            validateSubject.send(completion: completion)
        }, receiveValue: { [unowned validateSubject] value in
            validateSubject.send(value)
        })
        self.input = Input(name: AnySubscriber(nameSink),
                           validate: AnySubscriber(validateSink))

    }
}
