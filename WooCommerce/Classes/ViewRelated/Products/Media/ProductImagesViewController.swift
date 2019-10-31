import UIKit
import WPMediaPicker
import Yosemite

class ProductImagesViewController: UIViewController {
    @IBOutlet weak var addButton: UIButton!

    @IBOutlet weak var imagesContainerView: UIView!

    private let siteID: Int

    private lazy var mediaPickingCoordinator: MediaLibraryMediaPickingCoordinator = {
        return MediaLibraryMediaPickingCoordinator(delegate: self)
    }()

    init(siteID: Int) {
        self.siteID = siteID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureAddButton()

        let action = MediaAction.retrieveMediaLibrary(siteID: siteID) { (mediaItems, error) in
        }
        ServiceLocator.stores.dispatch(action)
    }
}

// MARK: UI configurations
private extension ProductImagesViewController {
    func configureAddButton() {
        addButton.setTitle(NSLocalizedString("ADD PHOTOS", comment: ""), for: .normal)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.applyPrimaryButtonStyle()
    }
}

private extension ProductImagesViewController {
    // MARK: - Actions

    @objc func addTapped() {
        showOptionsMenu()
    }

    private func showOptionsMenu() {

        let pickingContext: MediaPickingContext
//        if pickerDataSource.totalAssetCount > 0 {
            pickingContext = MediaPickingContext(origin: self, view: addButton, barButtonItem: nil)
//        } else {
//            pickingContext = MediaPickingContext(origin: self, view: noResultsView.actionButton, blog: blog)
//        }

        mediaPickingCoordinator.present(context: pickingContext)
    }
}

// MARK: - WPMediaPickerViewControllerDelegate

extension ProductImagesViewController: WPMediaPickerViewControllerDelegate {

    func emptyViewController(forMediaPickerController picker: WPMediaPickerViewController) -> UIViewController? {
        // TODO
        return self
    }

    func mediaPickerController(_ picker: WPMediaPickerViewController, didUpdateSearchWithAssetCount assetCount: Int) {
//        updateNoResultsView(for: assetCount)
    }

    func mediaPickerController(_ picker: WPMediaPickerViewController, didFinishPicking assets: [WPMediaAsset]) {
        // We're only interested in the upload picker
        guard picker != self else { return }
//        pickerDataSource.searchCancelled()

        dismiss(animated: true)

//        guard ReachabilityUtils.isInternetReachable() else {
//            ReachabilityUtils.showAlertNoInternetConnection()
//            return
//        }

        guard let assets = assets as? [PHAsset],
            assets.count > 0 else { return }

        for asset in assets {
            let action = MediaAction.uploadMedia(siteID: siteID,
                                                 mediaAsset: asset) { (media, error) in
            }
            ServiceLocator.stores.dispatch(action)
//            let info = MediaAnalyticsInfo(origin: .mediaLibrary(.deviceLibrary), selectionMethod: .fullScreenPicker)
//            MediaCoordinator.shared.addMedia(from: asset, to: blog, analyticsInfo: info)
        }
    }

    func mediaPickerControllerDidCancel(_ picker: WPMediaPickerViewController) {
//        pickerDataSource.searchCancelled()

        picker.dismiss(animated: true)
    }

    func mediaPickerController(_ picker: WPMediaPickerViewController, willShowOverlayView overlayView: UIView, forCellFor asset: WPMediaAsset) {
//        guard let overlayView = overlayView as? CircularProgressView,
//            let media = asset as? Media else {
//            return
//        }
//        WPStyleGuide.styleProgressViewForMediaCell(overlayView)
//        switch media.remoteStatus {
//        case .processing:
//            if let progress = MediaCoordinator.shared.progress(for: media) {
//                overlayView.state = .progress(progress.fractionCompleted)
//            } else {
//                overlayView.state = .indeterminate
//            }
//        case .pushing:
//            if let progress = MediaCoordinator.shared.progress(for: media) {
//                overlayView.state = .progress(progress.fractionCompleted)
//            }
//        case .failed:
//            overlayView.state = .retry
//        default: break
//        }
//        configureAppearance(for: overlayView, with: media)
    }

    func mediaPickerController(_ picker: WPMediaPickerViewController, shouldShowOverlayViewForCellFor asset: WPMediaAsset) -> Bool {
//        if let media = asset as? Media {
//            return media.remoteStatus != .sync
//        }

        return false
    }

    func mediaPickerController(_ picker: WPMediaPickerViewController, previewViewControllerFor asset: WPMediaAsset) -> UIViewController? {
        guard picker == self else { return WPAssetViewController(asset: asset) }

//        guard let media = asset as? Media,
//            media.remoteStatus == .sync else {
//                return nil
//        }
//
//        WPAppAnalytics.track(.mediaLibraryPreviewedItem, with: blog)
        return mediaItemViewController(for: asset)
    }

    func mediaPickerController(_ picker: WPMediaPickerViewController, shouldSelect asset: WPMediaAsset) -> Bool {
        guard picker == self else {
            return true
        }
        return true

//        guard let media = asset as? Media else {
//            return false
//        }

//        guard !isEditing else {
//            return media.remoteStatus == .sync || media.remoteStatus == .failed
//        }
//
//        switch media.remoteStatus {
//        case .failed, .pushing, .processing:
//            presentRetryOptions(for: media)
//        case .sync:
//            if let viewController = mediaItemViewController(for: asset) {
//                WPAppAnalytics.track(.mediaLibraryPreviewedItem, with: blog)
//                navigationController?.pushViewController(viewController, animated: true)
//            }
//        default: break
//        }

        return false
    }

    func mediaPickerController(_ picker: WPMediaPickerViewController, didSelect asset: WPMediaAsset) {
        guard picker == self else { return }

        updateNavigationItemButtonsForCurrentAssetSelection()
    }

    func mediaPickerController(_ picker: WPMediaPickerViewController, didDeselect asset: WPMediaAsset) {
        guard picker == self else { return }

        updateNavigationItemButtonsForCurrentAssetSelection()
    }

    @objc func updateNavigationItemButtonsForCurrentAssetSelection() {
        if isEditing {
            navigationItem.rightBarButtonItem?.isEnabled = true
            // Check that our selected items haven't been deleted – we're notified
            // of changes to the data source before the collection view has
            // updated its selected assets.
//            guard let assets = (selectedAssets as? [Media]) else { return }
//            let existingAssets = assets.filter({ !$0.isDeleted })

//            navigationItem.rightBarButtonItem?.isEnabled = (existingAssets.count > 0)
        }
    }

    private func mediaItemViewController(for asset: WPMediaAsset) -> UIViewController? {
        if isEditing { return nil }

        // TODO
        return nil

//        guard let asset = asset as? Media else {
//            return nil
//        }
//
//        selectedAsset = asset
//
//        return MediaItemViewController(media: asset)
    }

    func mediaPickerControllerWillBeginLoadingData(_ picker: WPMediaPickerViewController) {
        guard picker == self else { return }

//        isLoading = true
//
//        updateNoResultsView(for: pickerDataSource.numberOfAssets())
    }

    func mediaPickerControllerDidEndLoadingData(_ picker: WPMediaPickerViewController) {
        guard picker == self else { return }

//        isLoading = false
//
//        updateViewState(for: pickerDataSource.numberOfAssets())
    }
}

// MARK: - UIDocumentPickerDelegate

extension ProductImagesViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        for documentURL in urls as [NSURL] {
//            let info = MediaAnalyticsInfo(origin: .mediaLibrary(.otherApps), selectionMethod: .documentPicker)
//            MediaCoordinator.shared.addMedia(from: documentURL, to: blog, analyticsInfo: info)
//        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true)
    }
}
