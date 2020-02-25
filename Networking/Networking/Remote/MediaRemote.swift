import Foundation

/// Media: Remote Endpoints
///
public class MediaRemote: Remote {
    public func retrieveMediaLibrary(for siteID: Int64,
                                     pageFirstIndex: Int = Constants.pageFirstIndex,
                                     pageNumber: Int = Constants.pageFirstIndex,
                                     pageSize: Int = 25,
                                     context: String? = nil,
                                     completion: @escaping (_ mediaItems: [Media]?, _ error: Error?) -> Void) {
        let parameters: [String: Any] = [
            ParameterKey.contextKey: context ?? Default.context,
            ParameterKey.perPage: pageSize,
            ParameterKey.pageNumber: pageNumber - pageFirstIndex + Constants.pageFirstIndex,
            ParameterKey.fields: "ID,date,URL,thumbnails,title,alt,extension,mime_type",
            ParameterKey.mimeType: "image"
        ]

        let path = "sites/\(siteID)/media"
        let request = DotcomRequest(wordpressApiVersion: .mark1_1,
                                    method: .get,
                                    path: path,
                                    parameters: parameters)
        let mapper = MediaListEnvelopeMapper()

        enqueue(request, mapper: mapper) { (mediaListEnvelope, error) in
            guard let mediaList = mediaListEnvelope?.mediaList, error == nil else {
                completion(nil, error)
                return
            }

            completion(mediaList, nil)
        }
    }

    /// Uploads an array of media in the local file system.
    ///
    /// - Parameters:
    ///     - siteID: Site for which we'll upload the media to.
    ///     - context: Display or edit. Scope under which the request is made;
    ///                determines fields present in response. Default is Display.
    ///     - mediaItems: An array of uploadable media items.
    ///     - completion: Closure to be executed upon completion.
    ///
    public func uploadMedia(for siteID: Int64,
                            context: String? = Default.context,
                            mediaItems: [UploadableMedia],
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
    enum Default {
        public static let context: String = "display"
    }

    enum Constants {
        public static let pageFirstIndex = 1
    }

    private enum ParameterKey {
        static let pageNumber: String = "page"
        static let perPage: String    = "number"
        static let fields: String     = "fields"
        static let mimeType: String   = "mime_type"
        static let contextKey: String = "context"
    }
}
