import Foundation

public struct UploadableMedia {
    public let localURL: URL
    public let filename: String
    public let mimeType: String

    public init(localURL: URL, filename: String, mimeType: String) {
        self.localURL = localURL
        self.filename = filename
        self.mimeType = mimeType
    }
}
