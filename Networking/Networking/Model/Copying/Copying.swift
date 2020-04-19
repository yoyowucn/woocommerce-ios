
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

extension Copiable where Wrapped == Codable {
    public static let copy: Wrapped? = nil
}

extension NullableCopiable where Wrapped == Codable? {
    public static let nullify = Self.some(nil)
}
