// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT



extension ProductImage {
    public func copy(
        imageID: Copiable<Int64> = .copy,
        dateCreated: Copiable<Date> = .copy,
        dateModified: NullableCopiable<Date> = .copy,
        src: Copiable<String> = .copy,
        name: NullableCopiable<String> = .copy,
        alt: NullableCopiable<String> = .copy
    ) -> ProductImage {
        let imageID = imageID ?? self.imageID
        let dateCreated = dateCreated ?? self.dateCreated
        let dateModified = dateModified ?? self.dateModified
        let src = src ?? self.src
        let name = name ?? self.name
        let alt = alt ?? self.alt

        return ProductImage(
            imageID: imageID,
            dateCreated: dateCreated,
            dateModified: dateModified,
            src: src,
            name: name,
            alt: alt
        )
    }
}
