import WPMediaPicker
import Yosemite
import WordPressShared

final class WordPressMediaLibraryMediaGroup: NSObject, WPMediaGroup {
    private var mediaItems: [Media]
    init(mediaItems: [Media]) {
        self.mediaItems = mediaItems
        super.init()
    }

    func name() -> String {
        return NSLocalizedString("WordPress Media Library", comment: "")
    }

    func image(with size: CGSize, completionHandler: @escaping WPMediaImageBlock) -> WPMediaRequestID {
        return 0
    }

    func cancelImageRequest(_ requestID: WPMediaRequestID) {}

    func baseGroup() -> Any {
        return ""
    }

    func identifier() -> String {
        return "group id"
    }

    func numberOfAssets(of mediaType: WPMediaType, completionHandler: WPMediaCountBlock? = nil) -> Int {
        return mediaItems.count
    }
}


final class WordPressMediaLibraryPickerDataSource: NSObject {
    private var loadMedia: LoadMedia
    typealias LoadMedia = (_ onCompletion: @escaping (_ mediaItems: [Media], _ error: Error?) -> Void) -> Void
    private var onDataChange: WPMediaChangesBlock?

    private var mediaItems: [Media]
    private let siteID: Int64

    private lazy var mediaGroup: WPMediaGroup = {
        return WordPressMediaLibraryMediaGroup(mediaItems: mediaItems)
    }()

    init(siteID: Int64, loadMedia: @escaping LoadMedia) {
        self.siteID = siteID
        self.mediaItems = []
        self.loadMedia = loadMedia
        super.init()
    }

    func updateMediaItems(_ mediaItems: [Media]) {
        self.mediaItems = mediaItems
        onDataChange?(false, [], [], [], [])
    }
}

extension WordPressMediaLibraryPickerDataSource: WPMediaCollectionDataSource {

    func numberOfGroups() -> Int {
        return 1
    }

    func group(at index: Int) -> WPMediaGroup {
        return mediaGroup
    }

    func selectedGroup() -> WPMediaGroup? {
        return mediaGroup
    }

    func setSelectedGroup(_ group: WPMediaGroup) {}

    func numberOfAssets() -> Int {
        return mediaItems.count
    }

    func media(at index: Int) -> WPMediaAsset {
        let media = mediaItems[index]
        return media
    }

    func media(withIdentifier identifier: String) -> WPMediaAsset? {
        return mediaItems.first(where: { "\($0.mediaID)" == identifier })
    }

    func registerChangeObserverBlock(_ callback: @escaping WPMediaChangesBlock) -> NSObjectProtocol {
        onDataChange = callback
        return NSString()
    }

    func registerGroupChangeObserverBlock(_ callback: @escaping WPMediaGroupChangesBlock) -> NSObjectProtocol {
        // The group never changes
        return NSNull()
    }

    func unregisterChangeObserver(_ blockKey: NSObjectProtocol) {
        onDataChange = nil
    }

    func unregisterGroupChangeObserver(_ blockKey: NSObjectProtocol) {
        // The group never changes
    }

    func loadData(with options: WPMediaLoadOptions, success successBlock: WPMediaSuccessBlock?, failure failureBlock: WPMediaFailureBlock? = nil) {
        loadMedia { [weak self] (mediaItems, error) in
            guard error == nil else {
                failureBlock?(error)
                return
            }
            self?.mediaItems = mediaItems
            successBlock?()
        }
    }

    func add(_ image: UIImage, metadata: [AnyHashable : Any]?, completionBlock: WPMediaAddedBlock? = nil) {}

    func addVideo(from url: URL, completionBlock: WPMediaAddedBlock? = nil) {}

    func setMediaTypeFilter(_ filter: WPMediaType) {}

    func mediaTypeFilter() -> WPMediaType {
        return .all
    }

    func setAscendingOrdering(_ ascending: Bool) {}

    func ascendingOrdering() -> Bool {
        return true
    }
}
