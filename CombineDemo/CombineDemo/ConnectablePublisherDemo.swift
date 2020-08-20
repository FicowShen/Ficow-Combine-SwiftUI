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
        let url = URL(string: "https://ficow.cn")!
        let connectable = URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .catch() { _ in Just(Data()) }
            .share()
            .makeConnectable()
        
        cancellable1 = connectable
            .sink(receiveCompletion: { print("Received completion 1: \($0).") },
                  receiveValue: { print("Received data 1: \($0.count) bytes.") })
        
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
