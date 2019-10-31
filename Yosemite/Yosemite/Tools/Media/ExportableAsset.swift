import Foundation


public enum MediaType {
    case image
    case video
    case document
    case powerpoint
    case audio
}

public protocol ExportableAsset: NSObjectProtocol {

    /// The MediaType for the asset
    ///
    var assetMediaType: MediaType { get }

}
