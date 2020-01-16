import UIKit
import WPMediaPicker
import Yosemite

final class ProductImagesService {
    private let siteID: Int64

    init(siteID: Int64) {
        self.siteID = siteID
    }

    func uploadMediaAssetToSiteMediaLibrary(asset: ExportableAsset, completion: @escaping (_ image: ProductImage?, _ error: Error?) -> Void) {
        let action = MediaAction.uploadMedia(siteID: siteID,
                                             mediaAsset: asset) { (media, error) in
                                                guard let media = media else {
                                                    completion(nil, error)
                                                    return
                                                }
                                                let productImage =
                                                    ProductImage(imageID: media.mediaID,
                                                                 dateCreated: media.date,
                                                                 dateModified: media.date,
                                                                 src: media.src,
                                                                 name: media.name,
                                                                 alt: media.alt)
                                                completion(productImage, nil)
        }
        ServiceLocator.stores.dispatch(action)
    }
}

/// Displays Product images with edit functionality.
///
final class ProductImagesViewController: UIViewController {
    typealias Completion = (_ images: [ProductImage]) -> Void

    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var addButtonBottomBorderView: UIView!
    @IBOutlet private weak var imagesContainerView: UIView!

    private let siteID: Int64
    private let productID: Int64
    private let productImagesService: ProductImagesService
    private var productImages: [ProductImage]

    private var productImageStatuses: [ProductImageStatus] {
        didSet {
            imagesViewController.updateProductImages(productImageStatuses)
        }
    }

    // Child view controller.
    private lazy var imagesViewController: ProductImagesCollectionViewController = {
        let viewController = ProductImagesCollectionViewController(images: productImageStatuses)
        return viewController
    }()

    private lazy var mediaPickingCoordinator: MediaPickingCoordinator = {
        return MediaPickingCoordinator(siteID: siteID,
                                       onCameraCaptureCompletion: self.onCameraCaptureCompletion,
                                       onDeviceMediaLibraryPickerCompletion: self.onDeviceMediaLibraryPickerCompletion(assets:),
                                       onWPMediaPickerCompletion: self.onWPMediaPickerCompletion(mediaItems:))
    }()

    private let onCompletion: Completion

    init(product: Product, productImagesService: ProductImagesService, completion: @escaping Completion) {
        self.siteID = product.siteID
        self.productID = product.productID
        self.productImagesService = productImagesService
        self.productImages = product.images
        self.productImageStatuses = product.images.map({ ProductImageStatus.remote(image: $0) })
        self.onCompletion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigation()
        configureAddButton()
        configureAddButtonBottomBorderView()
        configureImagesContainerView()
    }
}

// MARK: - UI configurations
//
private extension ProductImagesViewController {
    func configureNavigation() {
        title = NSLocalizedString("Photos", comment: "Product images (Product images page title)")

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(completeEditing))
    }

    func configureAddButton() {
        addButton.setTitle(NSLocalizedString("ADD PHOTOS", comment: "Action to add photos on the Product images screen"), for: .normal)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.applyPrimaryButtonStyle()
    }

    func configureAddButtonBottomBorderView() {
        addButtonBottomBorderView.backgroundColor = .systemColor(.separator)
    }

    func configureImagesContainerView() {
        imagesContainerView.backgroundColor = .basicBackground

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

    @objc func completeEditing() {
        onCompletion(productImages)
    }

    private func showOptionsMenu() {
        let pickingContext = MediaPickingContext(origin: self, view: addButton, barButtonItem: nil)
        mediaPickingCoordinator.present(context: pickingContext)
    }

}

// MARK: - Image upload to WP Media Library and Product
// TODO-jc: move these to a Product Images service
private extension ProductImagesViewController {
    func uploadMediaAssetToSiteMediaLibraryThenAddToProduct(asset: PHAsset) {
        productImagesService.uploadMediaAssetToSiteMediaLibrary(asset: asset) { [weak self] (productImage, error) in
            guard let productImage = productImage, error == nil else {
                self?.showErrorAlert(error: error)
                return
            }
            self?.updateProductImageStatus(asset: asset, productImage: productImage)
        }
    }

    func updateProductImageStatus(asset: PHAsset, productImage: ProductImage) {
        if let index = productImageStatuses.firstIndex(where: { status -> Bool in
            switch status {
            case .uploading(let uploadingAsset):
                return uploadingAsset == asset
            default:
                return false
            }
        }) {
            productImageStatuses[index] = .remote(image: productImage)
            productImages = [productImage] + productImages
        }
    }

    func addMediaToProduct(mediaItems: [Media]) {
        let productMediaItems = mediaItems.map({
            ProductImage(imageID: $0.mediaID,
            dateCreated: Date(),
            dateModified: nil,
            src: $0.src,
            name: $0.name,
            alt: $0.alt)
        })
        self.productImages = productImages + productMediaItems
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
        productImageStatuses = [.uploading(asset: mediaAsset)] + productImageStatuses
        uploadMediaAssetToSiteMediaLibraryThenAddToProduct(asset: mediaAsset)
    }
}

// MARK: Action handling for device media library picker
//
private extension ProductImagesViewController {
    func onDeviceMediaLibraryPickerCompletion(assets: [PHAsset]) {
        defer {
            dismiss(animated: true, completion: nil)
        }
        guard assets.isEmpty == false else {
            return
        }
        assets.forEach { asset in
            productImageStatuses = [.uploading(asset: asset)] + productImageStatuses
            uploadMediaAssetToSiteMediaLibraryThenAddToProduct(asset: asset)
        }
    }
}


// MARK: - Action handling for WordPress Media Library
//
private extension ProductImagesViewController {
    func onWPMediaPickerCompletion(mediaItems: [Media]) {
        addMediaToProduct(mediaItems: mediaItems)
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
        let cancel = UIAlertAction(title: NSLocalizedString(
            "OK",
            comment: "Dismiss button on the alert when there is an error updating the product"
        ), style: .cancel, handler: nil)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
}
