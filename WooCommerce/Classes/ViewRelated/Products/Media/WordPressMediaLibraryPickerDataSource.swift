import WPMediaPicker
import Yosemite
import WordPressShared

final class WordPressMediaLibraryMediaGroup: NSObject, WPMediaGroup {
    private let mediaItems: [Media]

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
    private var onDataChange: WPMediaChangesBlock?

    private var mediaItems: [Media]
    private let siteID: Int64

    private let syncingCoordinator: SyncingCoordinator

    private lazy var mediaGroup: WPMediaGroup = {
        return WordPressMediaLibraryMediaGroup(mediaItems: mediaItems)
    }()

    init(siteID: Int64) {
        self.siteID = siteID
        self.mediaItems = []
        self.syncingCoordinator = SyncingCoordinator(pageFirstIndex: Constants.pageFirstIndex, pageSize: Constants.numberOfItems)
        super.init()

        syncingCoordinator.delegate = self
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
        syncingCoordinator.ensureNextPageIsSynchronized(lastVisibleIndex: index)
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
        retrieveMedia(pageNumber: Constants.pageFirstIndex, pageSize: Constants.numberOfItems) { [weak self] (mediaItems, error) in
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

extension WordPressMediaLibraryPickerDataSource: SyncingCoordinatorDelegate {
    func sync(pageNumber: Int, pageSize: Int, onCompletion: ((Bool) -> Void)?) {
        retrieveMedia(pageNumber: pageNumber, pageSize: pageSize) { [weak self] (mediaItems, error) in
            guard error == nil else {
                return
            }
            self?.updateMediaItems(mediaItems, pageNumber: pageNumber, pageSize: pageSize)
        }
    }
}

private extension WordPressMediaLibraryPickerDataSource {
    func retrieveMedia(pageNumber: Int, pageSize: Int, completion: @escaping (_ mediaItems: [Media], _ error: Error?) -> Void) {
        let action = MediaAction.retrieveMediaLibrary(siteID: siteID,
                                                      pageFirstIndex: Constants.pageFirstIndex,
                                                      pageNumber: pageNumber,
                                                      pageSize: pageSize) { (mediaItems, error) in
                                                        guard mediaItems.isEmpty == false else {
                                                            completion([], error)
                                                            return
                                                        }
                                                        completion(mediaItems, nil)
        }
        ServiceLocator.stores.dispatch(action)
    }

    func updateMediaItems(_ newMediaItems: [Media], pageNumber: Int, pageSize: Int) {
        let startIndex = (pageNumber - Constants.pageFirstIndex) * pageSize
        let endIndex = min(startIndex + newMediaItems.count - 1, (pageNumber + 1 - Constants.pageFirstIndex) * pageSize - 1)

        guard mediaItems.count == startIndex else {
            assertionFailure("""
                Cannot update media items where the start index \(startIndex) is not continuous with the current media items of size \(mediaItems.count)
                """)
            return
        }

        mediaItems += newMediaItems
        onDataChange?(true, [], IndexSet(integersIn: startIndex...endIndex), [], [])
    }
}

private extension WordPressMediaLibraryPickerDataSource {
    enum Constants {
        static let numberOfItems: Int = 25
        static let pageFirstIndex: Int = 0
    }
}
