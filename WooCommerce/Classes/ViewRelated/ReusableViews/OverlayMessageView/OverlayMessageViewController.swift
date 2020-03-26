
import UIKit

/// A `ViewController` that shows the `OverlayMessageView`.
///
/// You can use `OverlayMessageView` directly. Using a `ViewController` just gives us more
/// opportunities in receiving view-related events like `viewWillAppear` in case we'd ever
/// need them.
///
/// This was primarily built to be used within `SearchUICommand`.
///
final class OverlayMessageViewController: UIViewController {

    private let text: String
    private let image: UIImage?

    private var overlayMessageView: OverlayMessageView?

    init(text: String, image: UIImage? = nil) {
        self.text = text
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureOverlayMessageView()
    }

    private func configureOverlayMessageView() {
        let messageView: OverlayMessageView = OverlayMessageView.instantiateFromNib()
        messageView.messageText = text
        messageView.messageImage = image

        messageView.attach(to: view)

        overlayMessageView = messageView
    }
}
