import MobileCoreServices
import WPMediaPicker
import Yosemite

/// Prepares the alert controller that will be presented when trying to add media to a site or Product.
final class MediaLibraryMediaPickingCoordinator {
    private let cameraCapture: CameraCaptureCoordinator
    private let mediaLibrary = DeviceMediaLibraryPicker()
    private let onWPMediaPickerCompletion: WordPressMediaLibraryImagePickerViewController.OnCompletion
    private let siteID: Int

    init(siteID: Int,
         delegate: WPMediaPickerViewControllerDelegate,
         onCameraCaptureCompletion: @escaping CameraCaptureCoordinator.OnCompletion,
         onWPMediaPickerCompletion: @escaping WordPressMediaLibraryImagePickerViewController.OnCompletion) {
        self.siteID = siteID
        mediaLibrary.delegate = delegate
        cameraCapture = CameraCaptureCoordinator(onCompletion: onCameraCaptureCompletion)
        self.onWPMediaPickerCompletion = onWPMediaPickerCompletion
    }

    func present(context: MediaPickingContext) {
        let origin = context.origin
        let fromView = context.view
        let buttonItem = context.barButtonItem

        let menuAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)

        if WPMediaCapturePresenter.isCaptureAvailable() {
            menuAlert.addAction(cameraAction(origin: origin, product: nil))
        }

        menuAlert.addAction(photoLibraryAction(origin: origin, product: nil))

        menuAlert.addAction(siteMediaLibraryAction(origin: origin, product: nil))

        menuAlert.addAction(cancelAction())

        menuAlert.popoverPresentationController?.sourceView = fromView
        menuAlert.popoverPresentationController?.sourceRect = fromView.bounds
        menuAlert.popoverPresentationController?.barButtonItem = buttonItem

        origin.present(menuAlert, animated: true)
    }
}

// MARK: Alert Actions
//
private extension MediaLibraryMediaPickingCoordinator {
    func cameraAction(origin: UIViewController, product: Product?) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Take Photo or Video", comment: "Menu option for taking an image or video with the device's camera."), style: .default, handler: { [weak self] action in
            self?.showCameraCapture(origin: origin, product: product)
        })
    }

    func photoLibraryAction(origin: UIViewController, product: Product?) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Choose from My Device", comment: "Menu option for selecting media from the device's photo library."), style: .default, handler: { [weak self] action in
            self?.showMediaPicker(origin: origin)
        })
    }

    func siteMediaLibraryAction(origin: UIViewController, product: Product?) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("WordPress Media Library", comment: "Menu option for selecting media from the site's media library."), style: .default, handler: { [weak self] action in
            self?.showSiteMediaPicker(origin: origin)
        })
    }

    func cancelAction() -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Dismiss the AlertView"), style: .cancel, handler: nil)
    }
}

// MARK: Alert Action Handlers
//
private extension MediaLibraryMediaPickingCoordinator {
    func showCameraCapture(origin: UIViewController, product: Product?) {
        cameraCapture.presentMediaCapture(origin: origin)
    }

    func showMediaPicker(origin: UIViewController) {
        mediaLibrary.presentPicker(origin: origin)
    }

    func showSiteMediaPicker(origin: UIViewController) {
        let wordPressMediaPickerViewController = WordPressMediaLibraryImagePickerViewController(siteID: siteID,
                                                                                                onCompletion: onWPMediaPickerCompletion)
        origin.present(wordPressMediaPickerViewController, animated: true)
    }
}
