import Foundation
import Networking
import WordPressKit
import Storage

public struct Media {
    public let imageID: Int
    public let date: Date    // gmt
    public let src: String
    public let name: String?
    public let alt: String?

    init?(remoteMedia: RemoteMedia) {
        guard let imageID = remoteMedia.mediaID?.intValue,
            let date = remoteMedia.date,
            let src = remoteMedia.url?.absoluteString else {
                return nil
        }
        self.imageID = imageID
        self.date = date
        self.src = src
        self.name = remoteMedia.title
        self.alt = remoteMedia.alt
    }
}

extension Media {
    func toRemoteMedia() -> RemoteMedia {
        let remoteMedia = RemoteMedia()
        remoteMedia.title = name
        remoteMedia.alt = alt
        return remoteMedia
    }
}

/// Networking Preferences
///
public struct Settings {

    /// UserAgent to be used for every Networking Request
    ///
    public static var userAgent = "WooCommerce iOS"
}

// MARK: - MediaStore
//
public final class MediaStore: Store {
    private let credentials: Credentials

    private lazy var sharedDerivedStorage: StorageType = {
        return storageManager.newDerivedStorage()
    }()

    /// Registers for supported Actions.
    ///
    override public func registerSupportedActions(in dispatcher: Dispatcher) {
        dispatcher.register(processor: self, for: MediaAction.self)
    }

    /// Receives and executes Actions.
    ///
    override public func onAction(_ action: Action) {
        guard let action = action as? MediaAction else {
            assertionFailure("MediaStore received an unsupported action")
            return
        }

        switch action {
        case .retrieveMediaLibrary(let siteID, let onCompletion):
            retrieveMediaLibrary(siteID: siteID, onCompletion: onCompletion)
        case .uploadMedia(let siteID, let mediaAsset, let onCompletion):
            uploadMedia(siteID: siteID, mediaAsset: mediaAsset, onCompletion: onCompletion)
        }
    }

    public init(dispatcher: Dispatcher, storageManager: StorageManagerType, network: Network, credentials: Credentials) {
        self.credentials = credentials
        super.init(dispatcher: dispatcher, storageManager: storageManager, network: network)
    }
}

private extension MediaStore {
    func retrieveMediaLibrary(siteID: Int, onCompletion: @escaping (_ mediaItems: [Media], _ error: Error?) -> Void) {
        let dotComRestApi = WordPressComRestApi(oAuthToken: credentials.authToken, userAgent: Settings.userAgent)

        let remote = MediaServiceRemoteREST(wordPressComRestApi: dotComRestApi, siteID: NSNumber(value: siteID))
        remote.getMediaLibrary(success: { (data) in
            guard let mediaItems = data as? [RemoteMedia] else {
//                let error = Error()
                onCompletion([], nil)
                return
            }
            onCompletion(mediaItems.compactMap({ Media(remoteMedia: $0) }), nil)
        }) { (error) in
            onCompletion([], error)
        }
    }

    func uploadMedia(siteID: Int, media: RemoteMedia, onCompletion: @escaping (_ uploadedMedia: Media?, _ error: Error?) -> Void) {
        let dotComRestApi = WordPressComRestApi(oAuthToken: credentials.authToken, userAgent: Settings.userAgent)

        let remote = MediaServiceRemoteREST(wordPressComRestApi: dotComRestApi, siteID: NSNumber(value: siteID))
        var progress: Progress? = Progress()

        // TODO-jc: error handling
        remote.uploadMedia(media, progress: &progress, success: { (data) in
            guard let data = data,
            let media = Media(remoteMedia: data) else {
            //                let error = Error()
                            onCompletion(nil, nil)
                            return
                        }
            onCompletion(media, nil)
        }) { (error) in
            onCompletion(nil, error)
        }
    }

    func uploadMedia(siteID: Int, mediaAsset: ExportableAsset, onCompletion: @escaping (_ uploadedMedia: Media?, _ error: Error?) -> Void) {
        let mediaImporter = MediaImportService()
        let remoteMedia = RemoteMedia()
        _ = mediaImporter.import(mediaAsset,
                             to: remoteMedia,
                             onCompletion: { [weak self] (remoteMedia) in
                                self?.uploadMedia(siteID: siteID,
                                                  media: remoteMedia,
                                                  onCompletion: { (uploadedMedia, error) in
                                                    onCompletion(uploadedMedia, error)
                                })
        }) { (error) in
            onCompletion(nil, error)
        }
    }
}
