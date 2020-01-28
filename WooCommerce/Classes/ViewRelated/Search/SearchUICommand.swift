import UIKit
import Yosemite

/// An interface for search UI associated with a generic model and cell view model.
protocol SearchUICommand {
    associatedtype Model
    associatedtype CellViewModel

    /// The placeholder of the search bar.
    var searchBarPlaceholder: String { get }

    associatedtype ResultsControllerModel: ResultsControllerMutableType where ResultsControllerModel.ReadOnlyType == Model
    /// Creates a results controller for the search results. The result model's readonly type matches the search result model.
    func createResultsController() -> ResultsController<ResultsControllerModel>

    /// The controller of the view to show if there are empty results.
    ///
    /// This will called by `SearchViewController` only when the search results are empty. It will
    /// only be called once and will be retained until `SearchViewController` is deallocated.
    ///
    /// For a simple implementation, use `SearchEmptyLabelViewController`.
    ///
    /// - SeeAlso: SearchEmptyLabelViewController
    ///
    func createEmptyViewController() -> UIViewController

    /// Creates a view model for the search result cell.
    ///
    /// - Parameter model: search result model.
    /// - Returns: a view model based on the search result model.
    func createCellViewModel(model: Model) -> CellViewModel

    /// Synchronizes the models matching a given keyword.
    func synchronizeModels(siteID: Int64,
                           keyword: String,
                           pageNumber: Int,
                           pageSize: Int,
                           onCompletion: ((Bool) -> Void)?)

    /// Called when user selects a search result.
    ///
    /// - Parameters:
    ///   - model: search result model.
    ///   - viewController: view controller where the user selects the search result.
    func didSelectSearchResult(model: Model, from viewController: UIViewController)
}
