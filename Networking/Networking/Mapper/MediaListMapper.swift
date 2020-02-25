/// Mapper: Media List
///
struct MediaListMapper: Mapper {
    /// (Attempts) to convert data into a Media list.
    ///
    func map(response: Data) throws -> [Media] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.Defaults.iso8601)
        return try decoder.decode(MediaListEnvelope.self, from: response).mediaList
    }
}

struct MediaListEnvelopeMapper: Mapper {
    /// (Attempts) to convert a dictionary into a Media list.
    ///
    func map(response: Data) throws -> MediaListEnvelope {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.Defaults.iso8601)
        return try decoder.decode(MediaListEnvelope.self, from: response)
    }
}

/// MediaListEnvelope Disposable Entity:
/// `Retrieve Media` endpoint returns the updated products document in the `media` key.
/// This entity allows us to do parse all the things with JSONDecoder.
///
struct MediaListEnvelope: Decodable {
    let mediaList: [Media]

    private enum CodingKeys: String, CodingKey {
        case mediaList = "media"
    }
}
