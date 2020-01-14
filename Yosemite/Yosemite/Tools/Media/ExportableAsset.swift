import Foundation
import MobileCoreServices

public enum MediaType {
    case image
    case video
    case document
    case powerpoint
    case audio
    case other

    public init(fileExtension: String) {
        let unmanagedFileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
        guard let fileUTI = unmanagedFileUTI?.takeRetainedValue() else {
            self = .document
            return
        }
        self.init(fileUTI: fileUTI)
    }

    public init(mimeType: String) {
        let unmanagedFileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)
        guard let fileUTI = unmanagedFileUTI?.takeRetainedValue() else {
            self = .document
            return
        }
        self.init(fileUTI: fileUTI)
    }

    init(fileUTI: CFString) {
        if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
            self = .image
        } else if (UTTypeConformsTo(fileUTI, kUTTypeVideo)) {
            self = .video
        } else if (UTTypeConformsTo(fileUTI, kUTTypeMovie)) {
            self = .video
        } else if (UTTypeConformsTo(fileUTI, kUTTypeMPEG4)) {
            self = .video
        } else if (UTTypeConformsTo(fileUTI, kUTTypePresentation)) {
            self = .powerpoint
        } else if (UTTypeConformsTo(fileUTI, kUTTypeAudio)) {
            self = .audio
        } else {
            self = .document
        }
    }
}

public protocol ExportableAsset: NSObjectProtocol {

    /// The MediaType for the asset
    ///
    var assetMediaType: MediaType { get }

}
