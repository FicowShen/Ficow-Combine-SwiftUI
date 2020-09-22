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
        return AnySubscriber<Output, Failure>(receiveSubscription: nil, receiveValue: { [weak self] value -> Subscribers.Demand in
            guard let self = self else { return .none }
            self.send(value)
            return .unlimited
        }, receiveCompletion: { [weak self] completion in
            self?.send(completion: completion)
        })
    }
}
