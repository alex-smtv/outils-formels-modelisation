import ProofKitLib

// --------- Custom

print("--------- Custom output ---------")
print()
print("Some examples of computation.")
print()

do {
    let P: Formula = "P"
    let Q: Formula = "Q"

    let f = ((P => Q) => P) => P 

    print("Original Formula: \(f)")
    print("Computed NNF    : \(f.nnf)")
    print("Computed DNF    : \(f.dnf)")
    print("Computed CNF    : \(f.cnf)")
}

print()

do {
    let P: Formula = "P"
    let Q: Formula = "Q"
    let R: Formula = "R"

    let f = (P || Q) => (Q || R)

    print("Original Formula: \(f)")
    print("Computed NNF    : \(f.nnf)")
    print("Computed DNF    : \(f.dnf)")
    print("Computed CNF    : \(f.cnf)")
}

print()

do {
    let a: Formula = "a"
    let b: Formula = "b"
    let c: Formula = "c"

    let f = !(a && (b || c))

    print("Original Formula: \(f)")
    print("Computed NNF    : \(f.nnf)")
    print("Computed DNF    : \(f.dnf)")
    print("Computed CNF    : \(f.cnf)")
}

print()
print()
print("--------- Original output ---------")
print()
print("Output originally found in main.swift.")
print()


// --------- Original

let a: Formula = "a"
let b: Formula = "b"
let f = a && b

print(f)

let booleanEvaluation = f.eval { (proposition) -> Bool in
    switch proposition {
        case "p": return true
        case "q": return false
        default : return false
    }
}
print(booleanEvaluation)

enum Fruit: BooleanAlgebra {

    case apple, orange

    static prefix func !(operand: Fruit) -> Fruit {
        switch operand {
        case .apple : return .orange
        case .orange: return .apple
        }
    }

    static func ||(lhs: Fruit, rhs: @autoclosure () throws -> Fruit) rethrows -> Fruit {
        switch (lhs, try rhs()) {
        case (.orange, .orange): return .orange
        case (_ , _)           : return .apple
        }
    }

    static func &&(lhs: Fruit, rhs: @autoclosure () throws -> Fruit) rethrows -> Fruit {
        switch (lhs, try rhs()) {
        case (.apple , .apple): return .apple
        case (_, _)           : return .orange
        }
    }

}

let fruityEvaluation = f.eval { (proposition) -> Fruit in
    switch proposition {
        case "p": return .apple
        case "q": return .orange
        default : return .orange
    }
}
print(fruityEvaluation)
