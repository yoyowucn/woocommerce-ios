import Foundation
import Alamofire

/// Product: Remote Endpoints
///
public class MediaRemote: Remote {

    // MARK: - Products

    /// Retrieves all of the `Products` available.
    ///
    /// - Parameters:
    ///     - siteID: Site for which we'll fetch remote products.
    ///     - context: view or edit. Scope under which the request is made;
    ///                determines fields present in response. Default is view.
    ///     - pageNumber: Number of page that should be retrieved.
    ///     - pageSize: Number of products to be retrieved per page.
    ///     - orderBy: the key to order the remote products. Default to product name.
    ///     - order: ascending or descending order. Default to ascending.
    ///     - completion: Closure to be executed upon completion.
    ///
    public func uploadMedia(for siteID: Int64,
                            context: String? = nil,
                            mediaItems: [MediaUploadable],
                            completion: @escaping ([Media]?, Error?) -> Void) {
        let parameters = [
            ParameterKey.contextKey: context ?? Default.context,
        ]

        let path = "sites/\(siteID)/media/new"
        let request = DotcomRequest(wordpressApiVersion: .mark1_1,
                                    method: .post,
                                    path: path,
                                    parameters: parameters)
        let mapper = MediaListMapper()

        enqueueMultipartFormDataUpload(request, mapper: mapper, multipartFormData: { multipartFormData in
            mediaItems.forEach { mediaItem in
                multipartFormData.append(mediaItem.localURL,
                                         withName: "media[]",
                                         fileName: mediaItem.filename,
                                         mimeType: mediaItem.mimeType)
            }
        }, completion: completion)
    }
}


// MARK: - Constants
//
public extension MediaRemote {
    enum OrderKey {
        case name
    }

    enum Order {
        case ascending
        case descending
    }

    enum Default {
        public static let pageSize: Int   = 25
        public static let pageNumber: Int = Remote.Default.firstPageNumber
        public static let context: String = "view"
    }

    private enum Path {
        static let products   = "products"
    }

    private enum ParameterKey {
        static let page: String       = "page"
        static let perPage: String    = "per_page"
        static let contextKey: String = "context"
        static let include: String    = "include"
        static let search: String     = "search"
        static let orderBy: String    = "orderby"
        static let order: String      = "order"
    }
}

private extension MediaRemote.OrderKey {
    var value: String {
        switch self {
        case .name:
            return "title"
        }
    }
}

private extension MediaRemote.Order {
    var value: String {
        switch self {
        case .ascending:
            return "asc"
        case .descending:
            return "desc"
        }
    }
}
