//
//  ConnectablePublisher.swift
//  CombineDemo
//
//  Created by FicowShen on 2020/6/24.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import Foundation
import Combine

// https://developer.apple.com/documentation/combine/controlling-publishing-with-connectable-publishers
final class ConnectablePublisherDemo {
    
    private var cancellable1: AnyCancellable?
    private var cancellable2: AnyCancellable?
    private var cancellable3: AnyCancellable?
    
    private var connection: Cancellable?
    
    func run() {
        runMakeConnectableDemo()
        runAutocnnectDemo()
    }
    
    private func runMakeConnectableDemo() {
        let url = URL(string: "https://api.github.com/repos/johnsundell/publish")!
        let publisher = URLSession.shared.dataTaskPublisher(for: url)
        
        let connectable = publisher.map(\.data)
            .catch() { _ in Just(Data()) }
            .share()
            .makeConnectable()
        
        cancellable1 = connectable.sink(
            receiveCompletion: { completion in
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
            log(value)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.cancellable2 = connectable.sink(receiveCompletion: { log("Received completion 2: \($0).") },
                                                 receiveValue: { log("Received data 2: \($0.count) bytes.") })
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.connection = connectable.connect()
        }
    }
    
    private func runAutocnnectDemo() {
        cancellable3 = Timer.publish(every: 1, on: .main, in: .default)
        .autoconnect()
        .sink() { date in
            log("Date now: \(date)")
         }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.cancellable3?.cancel()
        }
    }
}
