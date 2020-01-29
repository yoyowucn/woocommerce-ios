
import Foundation
import UIKit

final class OrderSearchEmptyViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!

    private lazy var viewModel = OrderSearchEmptyViewModel()

    init() {
        super.init(nibName: type(of: self).nibName, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()

        #warning("temp")
        tableView.backgroundColor = .red
    }

    private func configureTableView() {
        viewModel.configureDataSource(for: tableView)
    }
}
