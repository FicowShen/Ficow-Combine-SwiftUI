//
//  StaticSayHelloViewModelTests.swift
//  CombineDemoTests
//
//  Created by Ficow on 2020/9/21.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import XCTest
import Combine

@testable import CombineDemo

final class StaticSayHelloViewModelTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        cancellables = Set<AnyCancellable>()
    }

    func testStaticSayHelloViewModel() throws {
        let viewModel = StaticSayHelloViewModel()

        // 构建用于测试的输入
        let namePublisher = PassthroughSubject<String, Never>()
        let validatePublisher = PassthroughSubject<Void, Never>()
        let input = StaticSayHelloViewModel.Input(name: namePublisher.eraseToAnyPublisher(), validate: validatePublisher.eraseToAnyPublisher())

        // 使用 expectation 来等待测试结果
        let expect = expectation(description: #function)
        var times = 0

        let output = viewModel.transform(input: input)

        output.greeting
            .sink { value in
                if times == 0 { // 因为使用了 prepend 操作符，所以第一次会发送空字符串
                    XCTAssertEqual(value, "")
                } else { // 第二次会发送拼接好的字符串
                    XCTAssertEqual(value, "Hello Ficow Shen!")
                    expect.fulfill()
                }
                times += 1
            }
            .store(in: &cancellables)

        namePublisher.send("Ficow Shen")
        validatePublisher.send(())

        wait(for: [expect], timeout: 3)
    }
}
