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
    
    private let currentValueSubject = CurrentValueSubject<Void, Never>(())
    private let passThroughtSubject = PassthroughSubject<Int, Never>()
    func run() {
        currentValueSubjectDemo()
        passThroughtSubjectDemo()
        
        currentValueSubject.send(())
        passThroughtSubject.send(5)
    }
    
    private func currentValueSubjectDemo() {
        cancellable1 = currentValueSubject.sink { log("sink:", $0) }
    }
    
    private func passThroughtSubjectDemo() {
        cancellable2 = passThroughtSubject.sink { log("sink:", $0) }
    }
}
