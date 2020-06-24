//
//  DeliverNotifications.swift
//  CombineDemo
//
//  Created by FicowShen on 2020/6/24.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import UIKit
import Combine

// https://developer.apple.com/documentation/combine/routing-notifications-to-combine-subscribers
final class NotificationPublisherDemo {
    
    private var notificationToken: NSObjectProtocol?
    private var cancellable: Cancellable?
    
    func run() {
        oldWay()
        useCombine()
    }
    
    private func oldWay() {
        notificationToken = NotificationCenter.default
            .addObserver(forName: UIDevice.orientationDidChangeNotification,
                         object: nil,
                         queue: nil) { _ in
                            if UIDevice.current.orientation == .portrait {
                                log("Orientation changed to portrait.")
                            }
        }
    }
    
    private func useCombine() {
        cancellable = NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .filter() { _ in UIDevice.current.orientation == .portrait }
            .sink() { _ in log("Orientation changed to portrait.") }
    }
}
