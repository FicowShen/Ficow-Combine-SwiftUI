//
//  CustomSubscriberWithBackPressure.swift
//  CombineDemo
//
//  Created by FicowShen on 2020/6/24.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import Foundation
import Combine

// https://developer.apple.com/documentation/combine/processing-published-elements-with-subscribers
// This concept of controlling flow by signaling a subscriber’s readiness
// to receive elements is called back pressure.
final class CustomSubscriberWithBackPressureDemo {
    
    /*
     Ways to make back pressure:
     By calling request(_:) on the Subscription instance that the publisher provided when the subscriber first subscribed.
     By returning a new demand when the publisher calls the subscriber’s receive(_:) method to deliver an element.
     */
    
    // Subscriber: Waits 5 seconds after subscription, then requests a
    // maximum of 3 values.
    class MySubscriber: Subscriber {
        typealias Input = Date
        typealias Failure = Never
        var subscription: Subscription?
        
        func receive(subscription: Subscription) {
            log("published                             received")
            self.subscription = subscription
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                subscription.request(.max(3))
            }
        }
        
        func receive(_ input: Date) -> Subscribers.Demand {
            log("\(input)             \(Date())")
            return Subscribers.Demand.none
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            log("--done--")
        }
    }
    
    // Publisher: Uses a timer to emit the date once per second.
    let timerPub = Timer.publish(every: 1, on: .main, in: .default)
        .autoconnect()
    
    func run() {
        useCustomSubscriber()
    }
    
    private func useCustomSubscriber() {
        // Subscribe to timerPub.
        let mySub = MySubscriber()
        log("Subscribing at \(Date())")
        timerPub.subscribe(mySub)
    }
    
    private func useOperators() {
        /*
         buffer(size:prefetch:whenFull:) holds onto a fixed number of items from an upstream publisher. When full, the buffer either drops elements or throws an error.

         debounce(for:scheduler:options:) publishes only when the upstream publisher stops publishing for a specified interval of time.

         throttle(for:scheduler:latest:) produces elements at a given maximum rate. If it receives multiple elements during an interval, it sends only the newest or oldest.

         collect(_:) and collect(_:options:) bundle elements until they exceed a given count or time interval, sending you an array of elements. This option is good if your subscriber can process multiple elements at the same time.
         */
    }
}
