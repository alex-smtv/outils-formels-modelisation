infix operator =>: LogicalDisjunctionPrecedence

public protocol BooleanAlgebra {

    static prefix func ! (operand: Self) -> Self
    static        func ||(lhs: Self, rhs: @autoclosure () throws -> Self) rethrows -> Self
    static        func &&(lhs: Self, rhs: @autoclosure () throws -> Self) rethrows -> Self

}

extension Bool: BooleanAlgebra {}

public enum Formula {

    /// p
    case proposition(String)

    /// ¬a
    indirect case negation(Formula)

    public static prefix func !(formula: Formula) -> Formula {
        return .negation(formula)
    }

    /// a ∨ b
    indirect case disjunction(Formula, Formula)

    public static func ||(lhs: Formula, rhs: Formula) -> Formula {
        return .disjunction(lhs, rhs)
    }

    /// a ∧ b
    indirect case conjunction(Formula, Formula)

    public static func &&(lhs: Formula, rhs: Formula) -> Formula {
        return .conjunction(lhs, rhs)
    }

    /// a → b
    indirect case implication(Formula, Formula)

    public static func =>(lhs: Formula, rhs: Formula) -> Formula {
        return .implication(lhs, rhs)
    }

    /// The negation normal form of the formula.
    public var nnf: Formula {
        switch self {
        case .proposition(_):
            return self
        case .negation(let a):
            switch a {
            case .proposition(_):
                return self
            case .negation(let b):
                return b.nnf
            case .disjunction(let b, let c):
                return (!b).nnf && (!c).nnf
            case .conjunction(let b, let c):
                return (!b).nnf || (!c).nnf
            case .implication(_):
                return (!a.nnf).nnf
            }
        case .disjunction(let b, let c):
            return b.nnf || c.nnf
        case .conjunction(let b, let c):
            return b.nnf && c.nnf
        case .implication(let b, let c):
            return (!b).nnf || c.nnf
        }
    }

    /// The disjunctive normal form of the formula.
    public var dnf: Formula {
        // Separate the logic in another private var. Why? we'll use a recursive pattern and the initial step should start with a nnf. 
        return self.nnf._dnf
    }

    // Should be called ONLY after computing nnf: nnf is the initial step of the recursive algorithm.
    private var _dnf: Formula {

        switch self {
            case .proposition(_):
                return self

            // Since nnf is the initial step, there's no negation applied to a group. A negation is only applied to a literal.
            case .negation(_):
                return self

            case .disjunction(let a, let b):
                return a._dnf || b._dnf
            
            // In a case of conjunction, first determine the existence of a disjunction in any of the two side.
            case .conjunction(let a, let b):

                // Case 1 -> a is a disjunction: apply the appropriate distributivity rule ("distribute b to a")
                switch a {
                    case .disjunction(let disjLeft, let disjRight):
                        return (b && disjLeft)._dnf || (b && disjRight)._dnf
                    default:
                        break
                }

                // Case 2 -> a is not a disjunction, but b is a disjuction: apply the appropriate distributivity rule ("distribute a to b")
                switch b {
                    case .disjunction(let disjLeft, let disjRight):
                        return (a && disjLeft)._dnf || (a && disjRight)._dnf
                    default:
                        break
                }

                // Case 3 -> neither a or b is a disjunction: keep the recursive algorithm running by calling the dnf computation of both side
                return a._dnf && b._dnf

            // In a nnf (and by extension dnf here), implications are not allowed.
            case .implication(_,_):
                fatalError("There sould be no implication in a nnf/dnf.")
        }

    }

    /// The conjunctive normal form of the formula.
    public var cnf: Formula {
        // Separate the logic in another private var. Why? we'll use a recursive pattern and the initial step should start with a nnf. 
        return self.nnf._cnf
    }

    // Should be called ONLY after computing nnf: nnf is the initial step of the recursive algorithm.
    private var _cnf: Formula {

        switch self {
            case .proposition(_):
                return self

            // Since nnf is the initial step, there's no negation applied to a group. A negation is only applied to a literal.
            case .negation(_):
                return self

            // In a case of disjunction, first determine the existence of a conjunction in any of the two side.
            case .disjunction(let a, let b):
                
                // Case 1 -> a is a conjunction: apply the appropriate distributivity rule ("distribute b to a")
                switch a {
                    case .conjunction(let disjLeft, let disjRight):
                        return (b || disjLeft)._cnf && (b || disjRight)._cnf
                    default:
                        break
                }

                // Case 2 -> a is not a conjunction, but b is a conjunction: apply the appropriate distributivity rule ("distribute a to b")
                switch b {
                    case .conjunction(let disjLeft, let disjRight):
                        return (a || disjLeft)._cnf && (a || disjRight)._cnf
                    default:
                        break
                }

                // Case 3 -> neither a or b is a conjunction: keep the recursive algorithm running by calling the cnf computation of both side
                return a._cnf || b._cnf
            
            case .conjunction(let a, let b):
                return a._cnf && b._cnf

            // In a nnf (and by extension cnf here), implications are not allowed.
            case .implication(_,_):
                fatalError("There sould be no implication in a nnf/cnf.")
        }
        
    }

    /// The propositions the formula is based on.
    ///
    ///     let f: Formula = (.proposition("p") || .proposition("q"))
    ///     let props = f.propositions
    ///     // 'props' == Set<Formula>([.proposition("p"), .proposition("q")])
    public var propositions: Set<Formula> {
        switch self {
        case .proposition(_):
            return [self]
        case .negation(let a):
            return a.propositions
        case .disjunction(let a, let b):
            return a.propositions.union(b.propositions)
        case .conjunction(let a, let b):
            return a.propositions.union(b.propositions)
        case .implication(let a, let b):
            return a.propositions.union(b.propositions)
        }
    }

    /// Evaluates the formula, with a given valuation of its propositions.
    ///
    ///     let f: Formula = (.proposition("p") || .proposition("q"))
    ///     let value = f.eval { (proposition) -> Bool in
    ///         switch proposition {
    ///         case "p": return true
    ///         case "q": return false
    ///         default : return false
    ///         }
    ///     })
    ///     // 'value' == true
    ///
    /// - Warning: The provided valuation should be defined for each proposition name the formula
    ///   contains. A call to `eval` might fail with an unrecoverable error otherwise.
    public func eval<T>(with valuation: (String) -> T) -> T where T: BooleanAlgebra {
        switch self {
        case .proposition(let p):
            return valuation(p)
        case .negation(let a):
            return !a.eval(with: valuation)
        case .disjunction(let a, let b):
            return a.eval(with: valuation) || b.eval(with: valuation)
        case .conjunction(let a, let b):
            return a.eval(with: valuation) && b.eval(with: valuation)
        case .implication(let a, let b):
            return !a.eval(with: valuation) || b.eval(with: valuation)
        }
    }

}

extension Formula: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self = .proposition(value)
    }

}

extension Formula: Hashable {

    public var hashValue: Int {
        return String(describing: self).hashValue
    }

    public static func ==(lhs: Formula, rhs: Formula) -> Bool {
        switch (lhs, rhs) {
        case (.proposition(let p), .proposition(let q)):
            return p == q
        case (.negation(let a), .negation(let b)):
            return a == b
        case (.disjunction(let a, let b), .disjunction(let c, let d)):
            return (a == c) && (b == d)
        case (.conjunction(let a, let b), .conjunction(let c, let d)):
            return (a == c) && (b == d)
        case (.implication(let a, let b), .implication(let c, let d)):
            return (a == c) && (b == d)
        default:
            return false
        }
    }

}

extension Formula: CustomStringConvertible {

    public var description: String {
        switch self {
        case .proposition(let p):
            return p
        case .negation(let a):
            return "¬\(a)"
        case .disjunction(let a, let b):
            return "(\(a) ∨ \(b))"
        case .conjunction(let a, let b):
            return "(\(a) ∧ \(b))"
        case .implication(let a, let b):
            return "(\(a) → \(b))"
        }
    }

}
