import Foundation

// MARK: - MediaAction: Defines media operations (supported by the MediaStore).
//
public enum MediaAction: Action {

    /// Retrieves all media from WP Media Library.
    ///
    case retrieveMediaLibrary(siteID: Int64, onCompletion: (_ mediaItems: [Media], _ error: Error?) -> Void)

    /// Uploads an exportable media asset to the site's WP Media Library.
    ///
    case uploadMedia(siteID: Int64, mediaAsset: ExportableAsset, onCompletion: (_ uploadedMedia: Media?, _ error: Error?) -> Void)
}
