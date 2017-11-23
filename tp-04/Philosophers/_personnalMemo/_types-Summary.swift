/// !!!!!!
/// This file is only meant to be used as a personnal memo and not in an actual project compilation.
/// !!!!!!

=== Variable
/// Type of variables on arc labels.
public typealias Variable = String


=== PredicateTransition<T>.Binding
/// Type for transition bindings.
public typealias Binding = [Variable: T]


=== PredicateLabel<T>.variable, PredicateLabel<T>.function
// Label de chaque arc qui est soit une variable, soit une fonction (de binding vers T, T est un type générique)
public enum PredicateLabel<T: Equatable> {

    case variable(Variable)
    case function((PredicateTransition<T>.Binding) -> T)

}


=== PredicateNet<T>.PlaceType, PredicateNet<T>.MarkingType
public typealias PlaceType   = String
public typealias MarkingType = [PlaceType: [T]]