//
//  LoginViewModel.swift
//  CombineLoginDemo
//
//  Created by FicowShen on 2020/8/27.
//  Copyright © 2020 ficow. All rights reserved.
//

import UIKit
import Combine

final class LoginViewModel: ViewModel {
    
    private let userStateManager: UserStateManaging
    private let loginService: LoginServiceProvider
    private let errorSubject = PassthroughSubject<Error, Never>()
    
    init(userStateManager: UserStateManaging, loginService: LoginServiceProvider) {
        self.userStateManager = userStateManager
        self.loginService = loginService
    }
    
    func transform(input: Input) -> Output {
        let canLogin = input.accountPublisher
            .combineLatest(input.passwordPublisher)
            .map { !$0.0.isEmpty && !$0.1.isEmpty }
            .eraseToAnyPublisher()
        
        let result = input.loginPublisher
            .withLatestFrom(
                input.accountPublisher.combineLatest(input.passwordPublisher)
            )
            .flatMap { [unowned self] (account, password) -> AnyPublisher<UserInfo, Never> in
                self.loginService
                    .login(account: account, password: password)
                    .catch { (error) -> Empty<UserInfo, Never> in
                        self.errorSubject.send(error)
                        return Empty(completeImmediately: true)
                }
                .eraseToAnyPublisher()
            }
            .map { [unowned self] userInfo -> UserInfo in
                self.userStateManager.userDidLogin(userInfo: userInfo)
                return userInfo
            }
            .eraseToAnyPublisher()
        
        return Output(canLogin: canLogin,
                      result: result,
                      error: errorSubject.eraseToAnyPublisher())
    }
    
}

extension LoginViewModel {
    struct Input {
        let accountPublisher: AnyPublisher<String, NotificationCenter.Publisher.Failure>
        let passwordPublisher: AnyPublisher<String, NotificationCenter.Publisher.Failure>
        let loginPublisher: AnyPublisher<UIControlPublisher<UIControl>.Output, UIControlPublisher<UIControl>.Failure>
    }
    struct Output {
        let canLogin: AnyPublisher<Bool, NotificationCenter.Publisher.Failure>
        let result: AnyPublisher<UserInfo, UIControlPublisher<UIControl>.Failure>
        let error: AnyPublisher<Error, Never>
    }
}
