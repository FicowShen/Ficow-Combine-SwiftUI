//
//  AsyncCode.swift
//  CombineDemo
//
//  Created by FicowShen on 2020/6/24.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import Foundation
import Combine

// https://developer.apple.com/documentation/combine/using-combine-for-your-app-s-asynchronous-code
final class AsyncCodeDemo {
    
    private var cancellable: Cancellable?
    private var cancellable2: Cancellable?
    
    private lazy var myDoSomethingSubject = PassthroughSubject<Void, Never>()
    lazy var doSomethingSubject = myDoSomethingSubject.eraseToAnyPublisher()
    
    func run() {
        oldWay()
        useFuture()
        useSubject()
        
        myDoSomethingSubject.send(())
    }
    
    private func oldWay() {
        performAsyncAction {
            log("callback")
            self.myDoSomethingSubject.send(completion: .finished)
        }
    }
    
    private func useFuture() {
        cancellable = useCombineFuture().sink { date in log("future", date) }
    }
    
    private func performAsyncAction(completionHandler: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline:.now() + 2) {
            completionHandler()
        }
    }
    
    private func useCombineFuture() -> Future<Date, Never> {
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline:.now() + 2) {
                promise(.success(Date()))
            }
        }
    }
    
    private func useSubject() {
        cancellable2 = doSomethingSubject
        .sink() { print("Did something with Combine.") }
    }
}

