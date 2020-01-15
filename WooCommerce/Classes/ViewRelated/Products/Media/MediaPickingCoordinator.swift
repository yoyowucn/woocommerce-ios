import MobileCoreServices
import WPMediaPicker
import Yosemite

/// Prepares the alert controller that will be presented when trying to add media to a site or Product.
///
final class MediaPickingCoordinator {
    private lazy var cameraCapture: CameraCaptureCoordinator = {
        return CameraCaptureCoordinator(onCompletion: onCameraCaptureCompletion)
    }()

    private lazy var deviceMediaLibraryPicker: DeviceMediaLibraryPicker = {
        return DeviceMediaLibraryPicker(onCompletion: onDeviceMediaLibraryPickerCompletion)
    }()

    private let siteID: Int64
    private let onCameraCaptureCompletion: CameraCaptureCoordinator.Completion
    private let onDeviceMediaLibraryPickerCompletion: DeviceMediaLibraryPicker.Completion
    private let onWPMediaPickerCompletion: WordPressMediaLibraryImagePickerViewController.Completion

    init(siteID: Int64,
         onCameraCaptureCompletion: @escaping CameraCaptureCoordinator.Completion,
         onDeviceMediaLibraryPickerCompletion: @escaping DeviceMediaLibraryPicker.Completion,
         onWPMediaPickerCompletion: @escaping WordPressMediaLibraryImagePickerViewController.Completion) {
        self.siteID = siteID
        self.onCameraCaptureCompletion = onCameraCaptureCompletion
        self.onDeviceMediaLibraryPickerCompletion = onDeviceMediaLibraryPickerCompletion
        self.onWPMediaPickerCompletion = onWPMediaPickerCompletion
    }

    func present(context: MediaPickingContext) {
        let origin = context.origin
        let fromView = context.view
        let buttonItem = context.barButtonItem

        let menuAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        menuAlert.view.tintColor = .text

        if WPMediaCapturePresenter.isCaptureAvailable() {
            menuAlert.addAction(cameraAction(origin: origin))
        }

        menuAlert.addAction(photoLibraryAction(origin: origin))

        menuAlert.addAction(siteMediaLibraryAction(origin: origin))

        menuAlert.addAction(cancelAction())

        menuAlert.popoverPresentationController?.sourceView = fromView
        menuAlert.popoverPresentationController?.sourceRect = fromView.bounds
        menuAlert.popoverPresentationController?.barButtonItem = buttonItem

        origin.present(menuAlert, animated: true)
    }
}

// MARK: Alert Actions
//
private extension MediaPickingCoordinator {
    func cameraAction(origin: UIViewController) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Take Photo or Video", comment: "Menu option for taking an image or video with the device's camera."), style: .default, handler: { [weak self] action in
            self?.showCameraCapture(origin: origin)
        })
    }

    func photoLibraryAction(origin: UIViewController) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Choose from My Device", comment: "Menu option for selecting media from the device's photo library."), style: .default, handler: { [weak self] action in
            self?.showDeviceMediaLibraryPicker(origin: origin)
        })
    }

    func siteMediaLibraryAction(origin: UIViewController) -> UIAlertAction {
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
private extension MediaPickingCoordinator {
    func showCameraCapture(origin: UIViewController) {
        cameraCapture.presentMediaCapture(origin: origin)
    }

    func showDeviceMediaLibraryPicker(origin: UIViewController) {
        deviceMediaLibraryPicker.presentPicker(origin: origin)
    }

    func showSiteMediaPicker(origin: UIViewController) {
        let wordPressMediaPickerViewController = WordPressMediaLibraryImagePickerViewController(siteID: siteID,
                                                                                                onCompletion: onWPMediaPickerCompletion)
        origin.present(wordPressMediaPickerViewController, animated: true)
    }
}
