/// !!!!!!
/// Ex-08
/// This file is only meant to be used as a personnal memo and not in an actual project compilation.
/// !!!!!!


do {

    // Dom(Igredients) = {p, t, m}
    enum Ingredients {
        case p,t, m
    }

    // Dom(Smokers) = {mia, tom, bob}
    enum Smokers {
        case mia, tom, bob
    }

    // Dom(Referee) = {rob}
    enum Referee {
        case rob
    }

    // Types = {Ingredients, Smokers, Referee}
    enum Types {
        case ingredients(Ingredients)
        case smokers(Smokers)
        case referee(Referee)
    }

    let s = PredicateTransition<Types>(
        preconditions: [
            PredicateArc(place: "i", label: [.variable("x"), .variable("y")]),
            PredicateArc(place: "s", label: [.variable("s")]),
        ],
        postconditions: [
            // _ : c'est la variable libre
            PredicateArc(place: "r", label: [.function({ _ in .referee(.rob) })]),
            PredicateArc(place: "w", label: [.variable("s")]),
        ],
        conditions: [{ binding in 

            guard case let .smokers(s)     = binding["s"]!,
                  case let .ingredients(x) = binding["x"]!,
                  case let .ingredients(y) = binding["y"]!
            else {
                return false
            }
        
            switch(s, x, y) {
                case (.mia, .p, .t): return true
                case (.tom, .p, .m): return true
                case (.bob, .t, .m): return true
                default            : return false
            }
        }])
    }
}