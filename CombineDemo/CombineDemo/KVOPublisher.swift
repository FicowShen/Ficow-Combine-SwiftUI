//
//  KVOPublisher.swift
//  CombineDemo
//
//  Created by FicowShen on 2020/6/24.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import Foundation
import Combine

// https://developer.apple.com/documentation/combine/performing-key-value-observing-with-combine
final class KVOPublisherDemo: NSObject {
    
    class UserInfo: NSObject {
        @objc dynamic var lastLogin: Date = Date(timeIntervalSince1970: 0)
    }
    
    @objc var userInfo = UserInfo()
    var observation: NSKeyValueObservation?
    var cancellable: Cancellable?
    
    func run() {
        oldWay()
        useCombine()
        
        userInfo.lastLogin = Date()
    }
    
    private func oldWay() {
        observation = observe(\.userInfo.lastLogin, options: [.new]) { object, change in
            print ("Old - lastLogin now \(change.newValue!).")
        }
    }
    
    private func useCombine() {
        cancellable = userInfo.publisher(for: \.lastLogin)
            .sink() { date in print ("Combine - lastLogin now \(date).") }
    }
    
}
