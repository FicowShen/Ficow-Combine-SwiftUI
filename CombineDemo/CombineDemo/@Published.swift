//
//  @Published.swift
//  CombineDemo
//
//  Created by FicowShen on 2020/6/24.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import UIKit
import Combine

// https://www.swiftbysundell.com/articles/published-properties-in-swift/
final class ProfileViewModel: ObservableObject {
    
    struct User {
        let id: String
        let name: String
    }
    
    enum State {
        case isLoading
        case failed(Error)
        case loaded(User)
    }

    // Simply marking a property with the @Published property wrapper
    // is enough to make the system emit observable events whenever
    // a new value was assigned to it.
    @Published private(set) var state = State.isLoading
    
    func setUserDidLoad() {
        state = .loaded(User(id: 1.description, name: "Ficow"))
    }
}

final class ProfileViewController: UIViewController {
    private let viewModel: ProfileViewModel
    private var cancellable: AnyCancellable?

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray

        // access the @Published property wrapper’s projected value (by prefixing its name with $),
        // which gives us access to a Combine publisher just for that property
        cancellable = viewModel.$state.sink { [weak self] state in
            self?.render(state)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.setUserDidLoad()
    }

    private func render(_ state: ProfileViewModel.State) {
        switch state {
        case .isLoading:
            // Show loading spinner
            log(state)
        case .failed(let error):
            // Show error view
            log(error)
        case .loaded(let user):
            // Show user's profile
            log(user)
        }
    }
}
