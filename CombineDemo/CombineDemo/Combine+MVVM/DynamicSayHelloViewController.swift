//
//  DynamicSayHelloViewController.swift
//  CombineDemo
//
//  Created by Ficow on 2020/9/21.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import UIKit
import Combine

/// 每个和 DynamicSayHelloViewModel 进行交互的 View 都需要遵循这个协议
protocol DynamicSayHelloViewModelBindable {
    var cancellable: Cancellable? { get }
    func bind(to viewModel: DynamicSayHelloViewModel)
}

final class TextFieldCell: UITableViewCell, DynamicSayHelloViewModelBindable {

    @IBOutlet weak var nameTextField: UITextField!
    var cancellable: Cancellable?

    override func prepareForReuse() {
        super.prepareForReuse()

        // 释放订阅
        cancellable = nil
    }

    func bind(to viewModel: DynamicSayHelloViewModel) {
        // 更新绑定时，需要将旧的绑定废弃。旧的 cancellable 引用计数为 0 时，旧的订阅即可被释放
        cancellable = nameTextField
            .textPublisher
            .bind(to: viewModel.input.name) // 动态地将输入框的内容绑定到 viewModel 的输入上
    }
}

final class ButtonCell: UITableViewCell, DynamicSayHelloViewModelBindable {

    @IBOutlet weak var validateButton: UIButton!
    var cancellable: Cancellable?

    override func prepareForReuse() {
        super.prepareForReuse()

        cancellable = nil
    }

    func bind(to viewModel: DynamicSayHelloViewModel) {
        cancellable = validateButton.publisher(for: .touchUpInside)
            .mapToVoid()
            .bind(to: viewModel.input.validate)
    }
}

final class GreetingCell: UITableViewCell, DynamicSayHelloViewModelBindable {

    @IBOutlet weak var greetingLabel: UILabel!
    var cancellable: Cancellable?

    override func prepareForReuse() {
        super.prepareForReuse()

        cancellable = nil
    }

    func bind(to viewModel: DynamicSayHelloViewModel) {
        cancellable = viewModel.output
            .greeting
            .assign(to: \.text, on: greetingLabel)
    }
}


final class DynamicSayHelloViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    static let cellIdentifiers = [
        "TextFieldCell",
        "ButtonCell",
        "GreetingCell"
    ]

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView() // 移除空白行
        }
    }

    private let viewModel = DynamicSayHelloViewModel()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Self.cellIdentifiers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifiers[indexPath.row], for: indexPath)
        (cell as? DynamicSayHelloViewModelBindable)?.bind(to: viewModel)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
