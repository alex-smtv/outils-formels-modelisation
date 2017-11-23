/// !!!!!!
/// Exemple du slide 29 de l'intro aux extensions
/// This file is only meant to be used as a personnal memo and not in an actual project compilation.
/// !!!!!!

do {
    // C est les types qu'on peut avoir: b,v,o
    enum C: CustomStringConvertible {
        case b, v, o

        var description: String {
            switch self {
            case .b: return "b"
            case .v: return "v"
            case .o: return "o"
            }
        }
    }

    // "Si x est b, je retourne v" : c'est la fonction g       (p*)
    func g(binding: PredicateTransition<C>.Binding) -> C {
        switch binding["x"]! {
        case .b: return .v
        case .v: return .b
        case .o: return .o
        }
    }

    let t1 = PredicateTransition<C>(
        preconditions: [
            // Remarque: Pour les multisets on utilise des tableaux ici (normalement multisets n'a pas d'ordre, mais on ne se sert pas de l'ordre donc c'est pas grave)
            // Label: soit une variable, soit une fonction
            // De la place p1, je veux le label avec la variable x
            PredicateArc(place: "p1", label: [.variable("x")]),
        ],
        postconditions: [
            // Label avec la fonction g
            PredicateArc(place: "p2", label: [.function(g)]),
        ])

    // p1 avec un multiset, etc.
    let m0: PredicateNet<C>.MarkingType = ["p1": [.b, .b, .v, .v, .b, .o], "p2": []]

    // Avec le fire on a donné le binding, à savoir x vaut b
    guard let m1 = t1.fire(from: m0, with: ["x": .b]) else {
        fatalError("Failed to fire.")
    }
    print(m1)
    guard let m2 = t1.fire(from: m1, with: ["x": .v]) else {
        fatalError("Failed to fire.")
    }
    print(m2)
}