import UIKit

/// Encapsulates context parameters to initiate a flow to pick media from several sources
struct MediaPickingContext {
    let origin: UIViewController
    let view: UIView
    let barButtonItem: UIBarButtonItem?

    init(origin: UIViewController, view: UIView, barButtonItem: UIBarButtonItem? = nil) {
        self.origin = origin
        self.view = view
        self.barButtonItem = barButtonItem
    }
}
