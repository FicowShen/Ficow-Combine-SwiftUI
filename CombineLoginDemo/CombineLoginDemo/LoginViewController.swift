import UIKit
import Combine
import CombineExt

final class LoginViewController: UIViewController {

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    private let viewModel = LoginViewModel(userStateManager: UserStateManager.shared,
                                           loginService: LoginService())
    private let loginService = LoginService()
    private let errorSubject = PassthroughSubject<Error, Never>()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.isEnabled = false
        bind()
    }

    private func bind() {
        let accountPublisher = accountTextField.textPublisher.eraseToAnyPublisher()
        let passwordPublisher = passwordTextField.textPublisher.eraseToAnyPublisher()
        let loginPublisher = loginButton.publisher(for: .touchUpInside).eraseToAnyPublisher()
        
        let input = LoginViewModel.Input(accountPublisher: accountPublisher,
                                         passwordPublisher: passwordPublisher,
                                         loginPublisher: loginPublisher)
        let output = viewModel.transform(input: input)
        
        output
            .canLogin
            .assign(to: \.isEnabled, on: loginButton)
            .store(in: &cancellables)
        
        output.result
            .receive(on: RunLoop.main)
            .sink { [unowned self] userInfo in
                self.navigateToHomepage()
            }
            .store(in: &cancellables)
        
        output.error
            .receive(on: RunLoop.main)
            .sink { [unowned self] error in
                self.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }

    private func navigateToHomepage() {
        dismiss(animated: true, completion: nil)
    }
}
