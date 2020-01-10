import Foundation

public struct MediaUploadable {
    public let localURL: URL
    public let filename: String
    public let mimeType: String
    // Metadata.
    public let caption: String?

    public init(localURL: URL, filename: String, mimeType: String, caption: String?) {
        self.localURL = localURL
        self.filename = filename
        self.mimeType = mimeType
        self.caption = caption
    }
}
