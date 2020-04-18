
import Foundation

/// Empty protocol used by Sourcery to generate a `copy()` method.
///
/// Only models that implement this protocol will have a generated `copy()` method. Please see the
/// docs on how to execute the `copy()` generation.
///
protocol Copiable {

}

typealias CopiableVal<Wrapped> = Optional<Wrapped>

typealias NullableCopiableVal<Wrapped> = Optional<Optional<Wrapped>>
