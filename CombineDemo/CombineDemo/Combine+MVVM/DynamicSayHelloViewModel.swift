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

    private let nameSubject = CurrentValueSubject<String, Never>("")
    private let validateSubject = PassthroughSubject<Void, Never>()

    init() {
        let greeting = validateSubject
            .withLatestFrom(nameSubject) { (_, name) in
                return name
            }
            .map { name -> String? in
                return "Hello \(name)!"
            }
            .prepend("")
            .eraseToAnyPublisher()

        self.output = Output(greeting: greeting)
        self.input = Input(name: nameSubject.asAnySubscriber(),
                           validate: validateSubject.asAnySubscriber())
    }
}

extension DynamicSayHelloViewModel {
    struct Input {
        // AnySubscriber 可以帮助隐藏内部的实现细节
        let name: AnySubscriber<String, Never>
        let validate: AnySubscriber<Void, Never>
    }

    struct Output {
        // AnyPublisher 可以帮助隐藏内部的实现细节
        let greeting: AnyPublisher<String?, Never>
    }
}
