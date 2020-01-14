import WPMediaPicker
import MobileCoreServices

/// Encapsulates launching and customization of a media picker to import media from the Photos Library.
///
final class DeviceMediaLibraryPicker: NSObject {
    typealias Completion = ((_ selectedMediaItems: [WPMediaAsset]) -> Void)
    private let onCompletion: Completion
    private let dataSource = WPPHAssetDataSource()

    init(onCompletion: @escaping Completion) {
        self.onCompletion = onCompletion
    }

    func presentPicker(origin: UIViewController) {
        let options = WPMediaPickerOptions()
        options.showMostRecentFirst = true
        options.filter = [.all]
        options.allowCaptureOfMedia = false
        options.badgedUTTypes = [String(kUTTypeGIF)]
        options.preferredStatusBarStyle = .lightContent

        let picker = WPNavigationMediaPickerViewController(options: options)
        picker.dataSource = dataSource
        picker.delegate = self

        origin.present(picker, animated: true)
    }
}

// MARK: - WPMediaPickerViewControllerDelegate
//
extension DeviceMediaLibraryPicker: WPMediaPickerViewControllerDelegate {

    func emptyViewController(forMediaPickerController picker: WPMediaPickerViewController) -> UIViewController? {
        return nil
    }

    func mediaPickerController(_ picker: WPMediaPickerViewController, didFinishPicking assets: [WPMediaAsset]) {
        // We're only interested in the upload picker
        guard picker != self else { return }

        picker.dismiss(animated: true)

        guard let assets = assets as? [PHAsset],
            assets.count > 0 else { return }

        onCompletion(assets)
    }

    func mediaPickerControllerDidCancel(_ picker: WPMediaPickerViewController) {
        onCompletion([])
    }
}
