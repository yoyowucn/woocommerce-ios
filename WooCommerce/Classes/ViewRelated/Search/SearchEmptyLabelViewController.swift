
import Foundation
import UIKit

/// A view controller that is primarily used to show a message that search results are empty.
///
/// This is generally used as a returned value of `SearchUICommand.createEmptyViewController`.
///
/// - SeeAlso: SearchUICommand
/// - SeeAlso: SearchViewController
///
class SearchEmptyLabelViewController: UIViewController {
    private let message: String
    private lazy var label = UILabel()

    init(message: String) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = message
        label.textColor = .textSubtle
        label.font = .headline
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10),
            label.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 100)
        ])
    }
}
