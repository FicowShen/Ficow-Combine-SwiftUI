import XCTest
import Combine
import CombineExt
@testable import CombineLoginDemo

final class LoginViewModelTests: BaseTest {

    private var viewModel: LoginViewModel!
    private var userStateManager: MockUserStateManager!
    private var loginService: MockLoginService!

    private var accountPublisher: PassthroughSubject<String, Never>!
    private var passwordPublisher: PassthroughSubject<String, Never>!
    private var loginPublisher: PassthroughSubject<Void, Never>!

    private var output: LoginViewModel.Output!

    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        userStateManager = MockUserStateManager()
        loginService = MockLoginService()
        viewModel = LoginViewModel(userStateManager: userStateManager,
                                   loginService: loginService)

        accountPublisher = PassthroughSubject<String, Never>()
        passwordPublisher = PassthroughSubject<String, Never>()
        loginPublisher = PassthroughSubject<Void, Never>()
        cancellables = Set<AnyCancellable>()

        let input = LoginViewModel.Input(accountPublisher: accountPublisher.eraseToAnyPublisher(),
                                         passwordPublisher: passwordPublisher.eraseToAnyPublisher(),
                                         loginPublisher: loginPublisher.eraseToAnyPublisher())
        output = viewModel.transform(input: input)
    }

    func testCanLogin() {
        var times = 0
        let expect = expectation(description: #function)
        output.canLogin
            .sink { canLogin in
                if times == 0 {
                    XCTAssertFalse(canLogin)
                } else {
                    XCTAssertTrue(canLogin)
                    expect.fulfill()
                }
                times += 1
            }
            .store(in: &cancellables)

        accountPublisher.send("1")

        passwordPublisher.send("")
        passwordPublisher.send("2")
        wait(for: [expect], timeout: 5)
    }

    func testLoginFailure() {

        loginService.shouldSucceed = false
        let expect = expectation(description: #function)

        output.error
            .sink { [unowned self] error in
                XCTAssertEqual(error.localizedDescription, "mock login should fail")
                XCTAssertFalse(self.userStateManager.ranUserDidLogin)
                expect.fulfill()
            }
            .store(in: &cancellables)

        output.result
            .sink { userInfo in
                XCTFail()
            }
            .store(in: &cancellables)

        accountPublisher.send("2")
        passwordPublisher.send("2")
        loginPublisher.send(())
        wait(for: [expect], timeout: 5)
    }

    func testLoginSuccess() {

        loginService.shouldSucceed = true
        let expect = expectation(description: #function)

        output.error
            .sink { error in
                XCTFail()
            }
            .store(in: &cancellables)

        output.result
            .sink { [unowned self] userInfo in
                XCTAssertEqual(1, userInfo.id)
                XCTAssertTrue(self.userStateManager.ranUserDidLogin)
                expect.fulfill()
            }
            .store(in: &cancellables)

        accountPublisher.send("3")
        passwordPublisher.send("3")
        loginPublisher.send(())
        wait(for: [expect], timeout: 5)
    }

}

private class MockUserStateManager: UserStateManaging {
    var hasLoggedIn: Bool { false }
    var loginStatusPublisher: AnyPublisher<Bool, Never> { Just(false).eraseToAnyPublisher() }

    var ranUserDidLogin = false

    func userDidLogin(userInfo: UserInfo) {
        ranUserDidLogin = true
    }

    func userDidLogout() {}
}

private class MockLoginService: LoginServiceProvider {

    var shouldSucceed = false

    func login(account: String, password: String) -> AnyPublisher<UserInfo, Error> {
        return Future() { [unowned self] promise in
            if self.shouldSucceed {
                promise(.success(UserInfo(id: 1, name: "1", type: "user", bio: "mock user")))
            } else {
                promise(.failure(NSError.makeError(description: "mock login should fail")))
            }
        }.eraseToAnyPublisher()
    }
}


