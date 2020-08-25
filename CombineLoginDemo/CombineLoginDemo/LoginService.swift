import Foundation
import Combine

struct UserInfo: Decodable {
    let id: String
    let name: String
    let type: String
    let bio: String
}

final class LoginService {

    private let url = "https://api.github.com/users/"

    func login(account: String, password: String) -> AnyPublisher<UserInfo, Error> {
        guard let url = URL(string: self.url.appending(account)) else {
            return Future { promise in
                promise(.failure(NSError.makeError(description: "Invalid request url")))
            }.eraseToAnyPublisher()
        }
        guard account == "ficowshen" && password == "1234" else {
            return Future { promise in
                DispatchQueue.main.asyncAfter(deadline:.now() + 1) {
                    promise(.failure(NSError.makeError(description: "Input correct account and password, please")))
                }
            }.eraseToAnyPublisher()
        }

        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: UserInfo.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

