//
//  DynamicSayHelloViewModel.swift
//  CombineDemoTests
//
//  Created by Ficow on 2020/9/23.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import XCTest
import Combine

@testable import CombineDemo

final class DynamicSayHelloViewModelTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        cancellables = Set<AnyCancellable>()
    }

    func testDynamicSayHelloViewModel() throws {
        let viewModel = DynamicSayHelloViewModel()

        // 使用 expectation 来等待测试结果
        let expect = expectation(description: #function)
        var times = 0

        viewModel.output
            .greeting
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

        // 用于测试的输入
        _ = viewModel.input.name.receive("Ficow Shen")
        _ = viewModel.input.validate.receive(())

        wait(for: [expect], timeout: 3)
    }
}
