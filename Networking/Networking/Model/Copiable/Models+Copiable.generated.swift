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
        ProductImage(
            imageID: imageID ?? self.imageID,
            dateCreated: dateCreated ?? self.dateCreated,
            dateModified: dateModified ?? self.dateModified,
            src: src ?? self.src,
            name: name ?? self.name,
            alt: alt ?? self.alt
        )
    }
}
