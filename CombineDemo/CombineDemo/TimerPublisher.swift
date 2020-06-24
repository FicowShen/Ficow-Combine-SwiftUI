//
//  TimerPublisher.swift
//  CombineDemo
//
//  Created by FicowShen on 2020/6/24.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import Foundation
import Combine

// https://developer.apple.com/documentation/combine/replacing-foundation-timers-with-timer-publishers
final class TimerPublisherDemo {
    
    private var timer: Timer?
    private var cancellable: Cancellable?
    
    private var currentDate = Date()
    
    func run() {
        oldWay()
        useCombine()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.timer?.invalidate()
            self.timer = nil
            self.cancellable?.cancel()
            self.cancellable = nil
            log(self.currentDate)
        }
    }
    
    private func oldWay() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            log(Date())
        }
    }
    
    private func useCombine() {
        cancellable = Timer.TimerPublisher(interval: 1, runLoop: .main, mode: .common)
            .autoconnect()
            .receive(on: RunLoop.main)
            .assign(to: \.currentDate, on: self)
    }
    
}
