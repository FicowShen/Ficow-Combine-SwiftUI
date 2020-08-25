import UIKit
import Combine

final class LoginViewController: UIViewController {

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    private let loginService = LoginService()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.isEnabled = false
        bind()
    }

    private func bind() {

        let accountPublisher = accountTextField.textPublisher
        let passwordPublisher = passwordTextField.textPublisher

        accountPublisher
            .combineLatest(passwordPublisher)
            .map { !$0.0.isEmpty && !$0.1.isEmpty }
            .assign(to: \.isEnabled, on: loginButton)
            .store(in: &cancellables)

        let loginPublisher = loginButton.publisher(for: .touchUpInside)

        loginPublisher
            .sink {
                print($0)
            }
            .store(in: &cancellables)

        Publishers
            .CombineLatest3(accountPublisher, passwordPublisher, loginPublisher)
            .setFailureType(to: Error.self)
            .flatMap { [unowned self] (account, password, _) -> AnyPublisher<UserInfo, Error> in
                self.loginService.login(account: account, password: password)
            }
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self?.showError(error)
                }
            }, receiveValue: { [weak self] userInfo in
                UserStateManager.shared.userDidLogin(userInfo: userInfo)
                self?.navigateToHomepage()
            })
            .store(in: &cancellables)
    }

    private func navigateToHomepage() {
        dismiss(animated: true, completion: nil)
    }

    private func showError(_ error: Error) {}


}

