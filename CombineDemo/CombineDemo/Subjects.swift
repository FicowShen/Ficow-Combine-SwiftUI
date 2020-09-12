//
//  Subjects.swift
//  CombineDemo
//
//  Created by FicowShen on 2020/6/24.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import Foundation
import Combine

final class SubjectsDemo {
    
    private var cancellable1: AnyCancellable?
    private var cancellable2: AnyCancellable?
    private var cancellable3: AnyCancellable?
    private var cancellable4: AnyCancellable?
    
    private let currentValueSubject = CurrentValueSubject<Int, Never>(1)
    private let passThroughtSubject = PassthroughSubject<Int, Never>()

    private let optionalCurrentValueSubject = CurrentValueSubject<Int?, Never>(nil)
    
    func run() {
//        passThroughtSubjectDemo()
//        currentValueSubjectDemo()
//        subjectSubscriber()
    }
    
    private func currentValueSubjectDemo() {
        cancellable1 = currentValueSubject
            .sink { [unowned self] in
                print(#function, $0)
                print("Value of currentValueSubject:", self.currentValueSubject.value)
            }
        currentValueSubject.send(2)
        currentValueSubject.send(3)
    }
    
    private func passThroughtSubjectDemo() {
        cancellable2 = passThroughtSubject
            .sink {
                print(#function, $0)
            }
        passThroughtSubject.send(1)
        passThroughtSubject.send(2)
        passThroughtSubject.send(3)
    }
    
    private func subjectSubscriber() {
        cancellable3 = optionalCurrentValueSubject
            .sink {
                print(#function, $0)
            }
        cancellable4 = [1, 2, 3].publisher
            .subscribe(optionalCurrentValueSubject) //
    }
}


enum ViewModelWithSubjectDemo {
    struct Model {
        let id: UUID
        let name: String
    }
    
    final class ViewModel {
        private let modelSubject = CurrentValueSubject<Model?, Never>(nil)
        var modelPublisher: AnyPublisher<Model?, Never> {
            return modelSubject.eraseToAnyPublisher()
        }
        
        func updateName(_ name: String) {
            modelSubject.send(.init(id: UUID(), name: name))
        }
    }
}


