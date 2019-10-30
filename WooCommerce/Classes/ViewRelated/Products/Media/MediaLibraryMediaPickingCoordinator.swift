import MobileCoreServices
import WPMediaPicker
import Yosemite

/// Prepares the alert controller that will be presented when tapping the "+" button in Media Library
final class MediaLibraryMediaPickingCoordinator {
    private let cameraCapture = CameraCaptureCoordinator()
    private let mediaLibrary = MediaLibraryPicker()

    init(delegate: WPMediaPickerViewControllerDelegate) {
        mediaLibrary.delegate = delegate
    }

    func present(context: MediaPickingContext) {
        let origin = context.origin
//        let blog = context.blog
        let fromView = context.view
        let buttonItem = context.barButtonItem

        let menuAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)

//        if let quotaUsageDescription = blog.quotaUsageDescription {
//            menuAlert.title = quotaUsageDescription
//        }

        if WPMediaCapturePresenter.isCaptureAvailable() {
            menuAlert.addAction(cameraAction(origin: origin, product: nil))
        }

        menuAlert.addAction(photoLibraryAction(origin: origin, product: nil))

        menuAlert.addAction(siteMediaLibraryAction(origin: origin, product: nil))

//        menuAlert.addAction(otherAppsAction(origin: origin, blog: blog))
        menuAlert.addAction(cancelAction())

        menuAlert.popoverPresentationController?.sourceView = fromView
        menuAlert.popoverPresentationController?.sourceRect = fromView.bounds
        menuAlert.popoverPresentationController?.barButtonItem = buttonItem

        origin.present(menuAlert, animated: true)
    }

    private func cameraAction(origin: UIViewController, product: Product?) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Take Photo or Video", comment: "Menu option for taking an image or video with the device's camera."), style: .default, handler: { [weak self] action in
            self?.showCameraCapture(origin: origin, product: product)
        })
    }

    private func photoLibraryAction(origin: UIViewController, product: Product?) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Choose from My Device", comment: "Menu option for selecting media from the device's photo library."), style: .default, handler: { [weak self] action in
            self?.showMediaPicker(origin: origin)
        })
    }

    private func siteMediaLibraryAction(origin: UIViewController, product: Product?) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("WordPress Media Library", comment: "Menu option for selecting media from the site's media library."), style: .default, handler: { [weak self] action in
            self?.showSiteMediaPicker(origin: origin)
        })
    }

//    private func freePhotoAction(origin: UIViewController, product: Product?) -> UIAlertAction {
//        return UIAlertAction(title: .freePhotosLibrary, style: .default, handler: { [weak self] action in
//            self?.showStockPhotos(origin: origin, blog: blog)
//        })
//    }

    private func cancelAction() -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Dismiss the AlertView"), style: .cancel, handler: nil)
    }

    private func showCameraCapture(origin: UIViewController, product: Product?) {
        cameraCapture.presentMediaCapture(origin: origin)
    }

//    private func showDocumentPicker(origin: UIViewController & UIDocumentPickerDelegate, blog: Blog) {
//        let docTypes = blog.allowedTypeIdentifiers
//        let docPicker = UIDocumentPickerViewController(documentTypes: docTypes, in: .import)
//        docPicker.delegate = origin
//        docPicker.allowsMultipleSelection = true
//        WPStyleGuide.configureDocumentPickerNavBarAppearance()
//        origin.present(docPicker, animated: true)
//    }

    private func showMediaPicker(origin: UIViewController) {
        mediaLibrary.presentPicker(origin: origin)
    }

    private func showSiteMediaPicker(origin: UIViewController) {
        let mediaPickerHelper = ProductMediaPickerHelper(context: origin)
        mediaPickerHelper.presentMediaPickerFullScreen(animated: true,
                                                       filter: .all,
        dataSourceType: .mediaLibrary,
        allowMultipleSelection: false,
        callback: {(assets) in
            print(assets)
//         guard let media = assets as? [Media] else {
//             callback(nil)
//             return
//         }
//         self.mediaInserterHelper.insertFromSiteMediaLibrary(media: media, callback: callback)
        })
    }
}
