import MobileCoreServices
import WPMediaPicker
import Yosemite

/// Encapsulates capturing media from a device camera
final class CameraCaptureCoordinator {
    private var capturePresenter: WPMediaCapturePresenter?

    typealias OnCompletion = ((_ media: PHAsset?, _ error: Error?) -> Void)
    private let onCompletion: OnCompletion

    init(onCompletion: @escaping OnCompletion) {
        self.onCompletion = onCompletion
    }

    func presentMediaCapture(origin: UIViewController) {
        capturePresenter = WPMediaCapturePresenter(presenting: origin)
        capturePresenter!.completionBlock = { [weak self] mediaInfo in
            if let mediaInfo = mediaInfo as NSDictionary? {
                self?.processMediaCaptured(mediaInfo)
            }
            self?.capturePresenter = nil
        }

        capturePresenter!.presentCapture()
    }

    private func processMediaCaptured(_ mediaInfo: NSDictionary) {
        let completionBlock: WPMediaAddedBlock = { [weak self] media, error in
            guard let media = media as? PHAsset else {
                print("Adding media failed: ", error?.localizedDescription ?? "no media")
                self?.onCompletion(nil, error)
                return
            }

            self?.onCompletion(media, nil)
//            let info = MediaAnalyticsInfo(origin: .mediaLibrary(.camera), selectionMethod: .fullScreenPicker)
//            MediaCoordinator.shared.addMedia(from: media, to: blog, analyticsInfo: info)
        }

        guard let mediaType = mediaInfo[UIImagePickerController.InfoKey.mediaType.rawValue] as? String else { return }

        switch mediaType {
        case String(kUTTypeImage):
            if let image = mediaInfo[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage,
                let metadata = mediaInfo[UIImagePickerController.InfoKey.mediaMetadata.rawValue] as? [AnyHashable: Any] {
                WPPHAssetDataSource().add(image, metadata: metadata, completionBlock: completionBlock)
            }
        case String(kUTTypeMovie):
            if let mediaURL = mediaInfo[UIImagePickerController.InfoKey.mediaURL.rawValue] as? URL {
                WPPHAssetDataSource().addVideo(from: mediaURL, completionBlock: completionBlock)
            }
        default:
            break
        }
    }
}
