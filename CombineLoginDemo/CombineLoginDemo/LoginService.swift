import Foundation
import Combine

struct UserInfo: Decodable {
    let id: Int
    let name: String
    let type: String
    let bio: String
}

protocol LoginServiceProvider {
    func login(account: String, password: String) -> AnyPublisher<UserInfo, Error>
}

final class LoginService: LoginServiceProvider {

    private let url = "https://api.github.com/users/"

    func login(account: String, password: String) -> AnyPublisher<UserInfo, Error> {
        guard let url = URL(string: self.url.appending(account)) else {
            return Fail(error: NSError.makeError(description: "Invalid request url"))
                .eraseToAnyPublisher()
        }
        guard account == "ficowshen" && password == "1234" else {
            return Future { promise in
                DispatchQueue.main.asyncAfter(deadline:.now() + 1) {
                    promise(.failure(NSError.makeError(description: "Wrong account/password")))
                }
            }.eraseToAnyPublisher()
        }

        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .map {
                // for debugging
                // print(String(data: $0, encoding: .utf8) ?? "")
                return $0
            }
            .decode(type: UserInfo.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

