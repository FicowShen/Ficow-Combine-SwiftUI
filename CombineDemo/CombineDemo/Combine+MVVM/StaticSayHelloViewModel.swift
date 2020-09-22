//
//  CombineMVVMStaticSolutionDemo.swift
//  CombineDemo
//
//  Created by Ficow on 2020/9/21.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import Foundation
import Combine

protocol StaticViewModel {
  associatedtype Input
  associatedtype Output

  func transform(input: Input) -> Output
}

final class StaticSayHelloViewModel: StaticViewModel {

  func transform(input: Input) -> Output {

    let greeting = input
        .validate
        .withLatestFrom(input.name) { (_, name) -> String in
            return name
        }
        .map { name -> String? in
            return "Hello \(name)!"
        }
        .prepend("")
        .eraseToAnyPublisher()

    return Output(greeting: greeting)
  }

}

extension StaticSayHelloViewModel {
    struct Input {
      let name: AnyPublisher<String, Never>
      let validate: AnyPublisher<Void, Never>
    }

    struct Output {
      let greeting: AnyPublisher<String?, Never>
    }
}
