
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

extension Copiable {
    public static var copy: Wrapped? { nil }
}
