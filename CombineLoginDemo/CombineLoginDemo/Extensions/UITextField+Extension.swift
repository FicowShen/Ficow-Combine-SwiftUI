import UIKit
import Combine

extension UITextField {
    var textPublisher: AnyPublisher<String, NotificationCenter.Publisher.Failure> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .map( { (($0.object as! UITextField).text ?? "") } )
            .eraseToAnyPublisher()
    }
}
