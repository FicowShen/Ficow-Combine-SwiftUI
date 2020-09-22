import UIKit

extension UIControl {
    func publisher(for event: UIControl.Event) -> UIControlPublisher<UIControl> {
        return .init(control: self, event: event)
    }
}
