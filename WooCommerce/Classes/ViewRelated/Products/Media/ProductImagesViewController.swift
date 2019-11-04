import UIKit
import WPMediaPicker
import Yosemite

class ProductImagesViewController: UIViewController {
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var imagesContainerView: UIView!

    private let siteID: Int
    private let productID: Int
    private var productImages: [ProductImage] {
        didSet {
            imagesViewController.updateProductImages(productImages)
        }
    }

    // Child view controller.
    private lazy var imagesViewController: ProductImagesCollectionViewController = {
        let viewController = ProductImagesCollectionViewController(images: productImages)
        return viewController
    }()

    private lazy var mediaPickingCoordinator: MediaLibraryMediaPickingCoordinator = {
        return MediaLibraryMediaPickingCoordinator(siteID: siteID,
                                                   delegate: self,
                                                   onCameraCaptureCompletion: self.onCameraCaptureCompletion,
                                                   onWPMediaPickerCompletion: self.onWPMediaPickerCompletion(assets:))
    }()

    init(product: Product) {
        self.siteID = product.siteID
        self.productID = product.productID
        self.productImages = product.images
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigation()
        configureAddButton()
        configureImagesContainerView()
    }
}

// MARK: - UI configurations
private extension ProductImagesViewController {
    func configureNavigation() {
        title = NSLocalizedString("Photos", comment: "Product images (Product images page title)")
    }

    func configureAddButton() {
        addButton.setTitle(NSLocalizedString("ADD PHOTOS", comment: ""), for: .normal)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.applyPrimaryButtonStyle()
    }

    func configureImagesContainerView() {
        imagesContainerView.backgroundColor = StyleManager.wooWhite

        addChild(imagesViewController)
        imagesContainerView.addSubview(imagesViewController.view)
        imagesViewController.didMove(toParent: self)

        imagesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        imagesContainerView.pinSubviewToSafeArea(imagesViewController.view)
    }
}

// MARK: - Actions
//
private extension ProductImagesViewController {

    @objc func addTapped() {
        showOptionsMenu()
    }

    private func showOptionsMenu() {
        let pickingContext = MediaPickingContext(origin: self, view: addButton, barButtonItem: nil)
        mediaPickingCoordinator.present(context: pickingContext)
    }
}

// MARK: - Image upload to WP Media Library and Product
private extension ProductImagesViewController {
    func uploadMediaAssetToProduct(asset: ExportableAsset) {
        let onMediaUploadToMediaLibrary = { [weak self] (media: Media) in
            self?.uploadMediaToProduct(mediaItems: [media])
        }

        let action = MediaAction.uploadMedia(siteID: siteID,
                                             mediaAsset: asset) { [weak self] (media, error) in
                                                guard let media = media else {
                                                    self?.showErrorAlert(error: error)
                                                    return
                                                }
                                                onMediaUploadToMediaLibrary(media)
        }
        ServiceLocator.stores.dispatch(action)
    }

    func uploadMediaToProduct(mediaItems: [Media]) {
        let productMediaItems = mediaItems.map({
            ProductImage(imageID: $0.mediaID,
            dateCreated: Date(),
            dateModified: nil,
            src: $0.src,
            name: $0.name,
            alt: $0.alt)
        })
        let images = productImages + productMediaItems
        let action = ProductAction.updateProductImages(siteID: siteID,
                                                       productID: productID,
                                                       images: images) { [weak self] (product, error) in
                                                        guard let product = product else {
                                                            self?.showErrorAlert(error: error)
                                                            return
                                                        }
                                                        // Update product images
                                                        self?.productImages = product.images
        }
        ServiceLocator.stores.dispatch(action)
    }
}

// MARK: - Action handling for camera capture
//
private extension ProductImagesViewController {

    func onCameraCaptureCompletion(mediaAsset: PHAsset?, error: Error?) {
        guard let mediaAsset = mediaAsset else {
            showErrorAlert(error: error)
            return
        }
        uploadMediaAssetToProduct(asset: mediaAsset)
    }
}

// MARK: - Action handling for camera capture
//
private extension ProductImagesViewController {

    func onWPMediaPickerCompletion(assets: [WPMediaAsset]) {
        guard let media = assets as? [Media] else {
            return
        }
        uploadMediaToProduct(mediaItems: media)
    }
}

// MARK: - WPMediaPickerViewControllerDelegate - action handling for device media library picker
//
extension ProductImagesViewController: WPMediaPickerViewControllerDelegate {

    func emptyViewController(forMediaPickerController picker: WPMediaPickerViewController) -> UIViewController? {
        return nil
    }

    func mediaPickerController(_ picker: WPMediaPickerViewController, didFinishPicking assets: [WPMediaAsset]) {
        // We're only interested in the upload picker
        guard picker != self else { return }

        picker.dismiss(animated: true)

        guard let assets = assets as? [PHAsset],
            assets.count > 0 else { return }

        for asset in assets {
            uploadMediaAssetToProduct(asset: asset)
        }
    }

    func mediaPickerControllerDidCancel(_ picker: WPMediaPickerViewController) {
        dismiss(animated: true)
    }
}

// MARK: Error handling
//
private extension ProductImagesViewController {
    func showErrorAlert(error: Error?) {
        let title = NSLocalizedString("Cannot upload image", comment: "")
        let alertController = UIAlertController(title: title,
                                                message: error?.localizedDescription,
                                                preferredStyle: .alert)
        present(alertController, animated: true)
    }
}
