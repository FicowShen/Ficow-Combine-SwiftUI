//
//  SayHelloViewController.swift
//  CombineDemo
//
//  Created by Ficow on 2020/9/21.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import UIKit
import Combine

final class StaticSayHelloViewController: UIViewController {

  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var validateButton: UIButton!
  @IBOutlet weak var greetingLabel: UILabel!

  private let viewModel = StaticSayHelloViewModel()
  private var cancellables = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()
    bindViewModel()
  }

  private func bindViewModel() {
    // 构建输入
    let namePublisher = nameTextField
                            .textPublisher
                            .eraseToAnyPublisher()
    let validatePublisher = validateButton
                                .publisher(for: .touchUpInside)
                                .mapToVoid()
                                .eraseToAnyPublisher()
    let inputs = StaticSayHelloViewModel.Input(name: namePublisher,
                                         validate: validatePublisher)
    // 根据输入构建输出
    let outputs = viewModel.transform(input: inputs)

    // 绑定输出和UI控件的属性
    outputs.greeting
        .assign(to: \.text, on: greetingLabel)
        .store(in: &cancellables)
  }
}
