
import Foundation

/// Empty protocol used by Sourcery to generate a `copy()` method.
///
/// Only models that implement this protocol will have a generated `copy()` method. Please see the
/// docs on how to execute the `copy()` generation.
///
protocol GeneratedCopying {

}

public typealias Copiable<Wrapped> = Optional<Wrapped>

public typealias NullableCopiable<Wrapped> = Optional<Optional<Wrapped>>

// MARK: - Copiable.copy and NullableCopiable.copy alias

extension Copiable where Wrapped == Codable {
    public static let copy: Wrapped? = nil
}

extension Copiable where Wrapped == String {
    public static let copy: Wrapped? = nil
}

extension Copiable where Wrapped == Int {
    public static let copy: Wrapped? = nil
}

extension Copiable where Wrapped == Int64 {
    public static let copy: Wrapped? = nil
}

extension Copiable where Wrapped == Date {
    public static let copy: Wrapped? = nil
}

// MARK: - NullableCopiable.nullify alias

extension NullableCopiable where Wrapped == Codable? {
    public static let nullify = Self.some(nil)
}

extension NullableCopiable where Wrapped == String? {
    public static let nullify = Self.some(nil)
}

extension NullableCopiable where Wrapped == Int? {
    public static let nullify = Self.some(nil)
}

extension NullableCopiable where Wrapped == Int64? {
    public static let nullify = Self.some(nil)
}

extension NullableCopiable where Wrapped == Date? {
    public static let nullify = Self.some(nil)
}
