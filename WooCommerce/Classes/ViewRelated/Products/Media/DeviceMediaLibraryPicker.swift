import WPMediaPicker
import MobileCoreServices

/// Encapsulates launching and customization of a media picker to import media from the Photos Library
final class DeviceMediaLibraryPicker: NSObject {
    private let dataSource = WPPHAssetDataSource()

    weak var delegate: WPMediaPickerViewControllerDelegate?

    func presentPicker(origin: UIViewController) {
        let options = WPMediaPickerOptions()
        options.showMostRecentFirst = true
        options.filter = [.all]
        options.allowCaptureOfMedia = false
        options.badgedUTTypes = [String(kUTTypeGIF)]
        options.preferredStatusBarStyle = .lightContent

        let picker = WPNavigationMediaPickerViewController(options: options)
        picker.dataSource = dataSource
        picker.delegate = delegate

        origin.present(picker, animated: true)
    }
}
