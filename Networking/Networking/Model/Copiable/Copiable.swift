
import Foundation

/// Empty protocol used by Sourcery to generate a `copy()` method.
///
/// Only models that implement this protocol will have a generated `copy()` method. Please see the
/// docs on how to execute the `copy()` generation.
///
protocol Copiable {

}

public typealias CopiableVal<Wrapped> = Optional<Wrapped>

public typealias NullableCopiableVal<Wrapped> = Optional<Optional<Wrapped>>

extension CopiableVal {
    public static var copy: Wrapped? { nil }
}
