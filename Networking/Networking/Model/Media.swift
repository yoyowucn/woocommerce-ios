/// WordPress.com Account
///
public final class Media: NSObject, Decodable {
    public let mediaID: Int64
    public let date: Date    // gmt iso8601
    public let src: String
    public let name: String?
    public let alt: String?
    // TODO-jc: add mime type
    public let height: Double?
    public let width: Double?

    /// Media initializer.
    ///
    public init(mediaID: Int64,
                date: Date,
                src: String,
                name: String?,
                alt: String?,
                height: Double?,
                width: Double?) {
        self.mediaID = mediaID
        self.date = date
        self.src = src
        self.name = name
        self.alt = alt
        self.height = height
        self.width = width
    }

    /// Public initializer for Media.
    ///
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let mediaID = try container.decode(Int64.self, forKey: .mediaID)
        let date = try container.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        let src = try container.decodeIfPresent(URL.self, forKey: .src)?.absoluteString ?? ""
        let name = try container.decode(String.self, forKey: .name)
        let alt = try container.decodeIfPresent(String.self, forKey: .alt)
        let height = try container.decodeIfPresent(Double.self, forKey: .height)
        let width = try container.decodeIfPresent(Double.self, forKey: .width)

        self.init(mediaID: mediaID,
                  date: date,
                  src: src,
                  name: name,
                  alt: alt,
                  height: height,
                  width: width)
    }
}

private extension Media {
    enum CodingKeys: String, CodingKey {
        case mediaID  = "ID"
        case date
        case src = "URL"
        case name = "title"
        case alt
        case height
        case width
    }
}
