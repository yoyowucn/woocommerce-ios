import Foundation
import Photos
import MobileCoreServices
import AVFoundation

extension PHAsset: ExportableAsset {
    public var assetMediaType: MediaType {
        switch mediaType {
        case .image:
            return .image
        case .video:
            return .video
        default:
            return .document
        }
     }
}
