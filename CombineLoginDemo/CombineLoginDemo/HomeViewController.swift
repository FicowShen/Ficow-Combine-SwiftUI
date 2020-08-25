import UIKit
import Combine

class HomeViewController: UIViewController {

    private var cancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UserStateManager.shared.hasLoggedIn {
            showLoginPage(animated: false)
        }
    }

    private func bind() {
        cancellable = UserStateManager.shared
            .userDidLoginPublisher
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

