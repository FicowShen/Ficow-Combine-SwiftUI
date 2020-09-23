//
//  Subject+Extension.swift
//  CombineDemo
//
//  Created by Ficow on 2020/9/23.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import Combine

extension Subject {
    func asAnySubscriber() -> AnySubscriber<Output, Failure> {
        // AnySubscriber(self) 虽然可以编译成功，但是无法得到预期的结果
        return AnySubscriber<Output, Failure>(
            receiveSubscription: { [weak self] subscription in
                guard let self = self else { return }
                self.send(subscription: subscription)
            },
            receiveValue: { [weak self] value -> Subscribers.Demand in
                guard let self = self else { return .none }
                self.send(value)
                return .unlimited
            },
            receiveCompletion: { [weak self] completion in
                self?.send(completion: completion)
            }
        )
    }
}
