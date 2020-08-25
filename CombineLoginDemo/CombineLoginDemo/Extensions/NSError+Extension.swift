import Foundation

extension NSError {
    static func makeError(description: String, code: Int = -1) -> Self {
        return Self(domain: "cn.ficow.blog",
                    code: code,
                    userInfo: [NSLocalizedDescriptionKey: description])
    }
}
