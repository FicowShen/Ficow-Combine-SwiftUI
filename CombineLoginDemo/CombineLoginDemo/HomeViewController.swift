import UIKit
import Combine

final class HomeViewController: UIViewController {

    var userStateManager: UserStateManaging = UserStateManager.shared

    private var cancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !userStateManager.hasLoggedIn {
            showLoginPage(animated: false)
        }
    }

    private func bind() {
        cancellable = userStateManager
            .loginStatusPublisher
            .sink { [weak self] hasLoggedIn in
                if !hasLoggedIn {
                    self?.showLoginPage(animated: true)
                }
        }
    }

    private func showLoginPage(animated: Bool) {
        if view.window == nil || presentedViewController is LoginViewController {
            return
        }
        let loginPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController")
        loginPage.modalPresentationStyle = .fullScreen
        present(loginPage, animated: animated, completion: nil)
    }
}

