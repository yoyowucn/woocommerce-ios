/// WordPress.com Account
///
public final class Media: NSObject, Decodable {
    public let mediaID: Int64
    public let date: Date    // gmt
    public let src: String
    public let name: String?
    public let alt: String?

    /// ProductShippingClass initializer.
    ///
    public init(mediaID: Int64,
                date: Date,
                src: String,
                name: String?,
                alt: String?) {
        self.mediaID = mediaID
        self.date = date
        self.src = src
        self.name = name
        self.alt = alt
    }

    /// Public initializer for ProductShippingClass.
    ///
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let mediaID = try container.decode(Int64.self, forKey: .mediaID)
        let date = try container.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        let src = try container.decodeIfPresent(URL.self, forKey: .src)?.absoluteString ?? ""
        let name = try container.decode(String.self, forKey: .name)
        let alt = try container.decodeIfPresent(String.self, forKey: .alt)

        self.init(mediaID: mediaID,
                  date: date,
                  src: src,
                  name: name,
                  alt: alt)
    }
}

private extension Media {
    enum CodingKeys: String, CodingKey {
        case mediaID  = "ID"
        case date
        case src = "URL"
        case name = "title"
        case alt
    }
}
