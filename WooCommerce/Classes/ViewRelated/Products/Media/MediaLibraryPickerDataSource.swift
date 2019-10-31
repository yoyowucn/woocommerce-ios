//import WPMediaPicker
//
//final class MediaLibraryPickerDataSource: NSObject {
//
//}
//
//extension MediaLibraryPickerDataSource: WPMediaCollectionDataSource {
//    func numberOfGroups() -> Int {
//        <#code#>
//    }
//
//    func group(at index: Int) -> WPMediaGroup {
//        <#code#>
//    }
//
//    func selectedGroup() -> WPMediaGroup? {
//        <#code#>
//    }
//
//    func setSelectedGroup(_ group: WPMediaGroup) {
//        <#code#>
//    }
//
//    func numberOfAssets() -> Int {
//        <#code#>
//    }
//
//    func media(at index: Int) -> WPMediaAsset {
//        <#code#>
//    }
//
//    func media(withIdentifier identifier: String) -> WPMediaAsset? {
//        <#code#>
//    }
//
//    func registerChangeObserverBlock(_ callback: @escaping WPMediaChangesBlock) -> NSObjectProtocol {
//        <#code#>
//    }
//
//    func registerGroupChangeObserverBlock(_ callback: @escaping WPMediaGroupChangesBlock) -> NSObjectProtocol {
//        <#code#>
//    }
//
//    func unregisterChangeObserver(_ blockKey: NSObjectProtocol) {
//        <#code#>
//    }
//
//    func unregisterGroupChangeObserver(_ blockKey: NSObjectProtocol) {
//        <#code#>
//    }
//
//    func loadData(with options: WPMediaLoadOptions, success successBlock: WPMediaSuccessBlock?, failure failureBlock: WPMediaFailureBlock? = nil) {
//        <#code#>
//    }
//
//    func add(_ image: UIImage, metadata: [AnyHashable : Any]?, completionBlock: WPMediaAddedBlock? = nil) {
//        <#code#>
//    }
//
//    func addVideo(from url: URL, completionBlock: WPMediaAddedBlock? = nil) {
//        <#code#>
//    }
//
//    func setMediaTypeFilter(_ filter: WPMediaType) {
//        <#code#>
//    }
//
//    func mediaTypeFilter() -> WPMediaType {
//        <#code#>
//    }
//
//    func setAscendingOrdering(_ ascending: Bool) {
//        <#code#>
//    }
//
//    func ascendingOrdering() -> Bool {
//        <#code#>
//    }
//
//
//}
