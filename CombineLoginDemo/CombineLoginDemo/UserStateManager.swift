import Foundation
import Combine

final class UserStateManager {

    static let shared = UserStateManager()

    var hasLoggedIn: Bool {
        return userDidLoginSubject.value
    }

    private(set) var userInfo: UserInfo?

    private let userDidLoginSubject = CurrentValueSubject<Bool, Never>(false)
    var userDidLoginPublisher: AnyPublisher<Bool, Never> {
        return userDidLoginSubject.eraseToAnyPublisher()
    }

    func userDidLogin(userInfo: UserInfo) {
        self.userInfo = userInfo
        saveUserInfo(userInfo: userInfo)
        userDidLoginSubject.send(true)
    }

    func userDidLogout() {
        userDidLoginSubject.send(false)
    }

    private func saveUserInfo(userInfo: UserInfo) {}
}
