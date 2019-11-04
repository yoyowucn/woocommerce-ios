import WPMediaPicker
import Yosemite
import WordPressShared

extension Media: WPMediaAsset {
    public func image(with size: CGSize, completionHandler: @escaping WPMediaImageBlock) -> WPMediaRequestID {
        guard let url = URL(string: src) else {
            return 0
        }
        WPImageSource.shared()?.downloadImage(for: url, withSuccess: { (image) in
            completionHandler(image, nil)
        }, failure: { (error) in
            completionHandler(nil, error)
        })
        return Int32(mediaID)
    }

    public func cancelImageRequest(_ requestID: WPMediaRequestID) {

    }

    public func videoAsset(completionHandler: @escaping WPMediaAssetBlock) -> WPMediaRequestID {
        return 0
    }

    public func assetType() -> WPMediaType {
        return .image
//        if (self.mediaType == MediaTypeImage) {
//            return WPMediaTypeImage;
//        } else if (self.mediaType == MediaTypeVideo) {
//            return WPMediaTypeVideo;
//        } else if (self.mediaType == MediaTypeAudio) {
//            return WPMediaTypeAudio;
//        } else {
//            return WPMediaTypeOther;
//        }
    }

    public func duration() -> TimeInterval {
        return 0
    }

    public func baseAsset() -> Any {
        return self
    }

    public func identifier() -> String {
        return "\(mediaID)"
    }

    public func date() -> Date {
        return date
    }

    public func pixelSize() -> CGSize {
        // TODO
        return CGSize(width: 30, height: 30)
    }
}

import WPMediaPicker

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

    func cancelImageRequest(_ requestID: WPMediaRequestID) {
        //
    }

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
    private let siteID: Int

    private lazy var mediaGroup: WPMediaGroup = {
        return WordPressMediaLibraryMediaGroup(mediaItems: mediaItems)
    }()

    init(siteID: Int, loadMedia: @escaping LoadMedia) {
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

    func setSelectedGroup(_ group: WPMediaGroup) {

    }

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
        return NSString()
    }

    func unregisterChangeObserver(_ blockKey: NSObjectProtocol) {
        onDataChange = nil
    }

    func unregisterGroupChangeObserver(_ blockKey: NSObjectProtocol) {

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

    func add(_ image: UIImage, metadata: [AnyHashable : Any]?, completionBlock: WPMediaAddedBlock? = nil) {

    }

    func addVideo(from url: URL, completionBlock: WPMediaAddedBlock? = nil) {

    }

    func setMediaTypeFilter(_ filter: WPMediaType) {

    }

    func mediaTypeFilter() -> WPMediaType {
        return .all
    }

    func setAscendingOrdering(_ ascending: Bool) {

    }

    func ascendingOrdering() -> Bool {
        return true
    }
}
