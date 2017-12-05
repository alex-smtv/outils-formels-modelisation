import ProofKitLib

// Ex 1.2
do {
    print("-------------------------------------------------------------")
    print(" >> EX 1.2")
    print("-------------------------------------------------------------")
    print()

    let a: Formula = "a"
    let b: Formula = "b"
    let c: Formula = "c"

    let j = (a || b) |- (a && c) || (b && c) || !c

    print("\nProvable ? \(j.isProvable)")
}

print()

// Ex 1.3
do {
    print("-------------------------------------------------------------")
    print(" >> EX 1.3")
    print("-------------------------------------------------------------")
    print()

    let a: Formula = "a"
    let b: Formula = "b"
    let c: Formula = "c"
    let d: Formula = "d"

    let j = (a => b) && (a => c) && (b => d) && (c => d) |- a => d
    
    print("\nProvable ? \(j.isProvable)")
}

print()

// Ex 1.4
do {
    print("-------------------------------------------------------------")
    print(" >> EX 1.4")
    print("-------------------------------------------------------------")
    print()

    let a: Formula = "a"
    let b: Formula = "b"

    let j = (a => b) && (b => a) |- (a => b) && (b => a)

    print("\nProvable ? \(j.isProvable)")
}

print()

// Ex 2
do {

    print("-------------------------------------------------------------")
    print(" >> EX 2")
    print("-------------------------------------------------------------")
    print()

    // S’il fait beau, on va à l’université.
    // S’il risque de pleuvoir, on ne va pas à l’université.
    // Si on n’est pas à la maison, on est à l’université.
    // Si on reste à la maison, on fait des exercices et on relit le cours.
    // Si le ciel est gris, il risque de pleuvoir.
    // Si on va à l’université, on fait des exercices et on est contents.
    // Soit il fait beau, soit le ciel est gris

    // A = il fait beau
    // B = on va à l'université
    // C = il risque de pleuvoir
    // D = on est à la maison
    // E = on fait des exercices
    // F = on relit le cours
    // G = le ciel est gris
    // H = on est content

    // etre à l'uni même chose que aller

    let f1: Formula = "il fait beau"
    let f2: Formula = "on va à l'université"
    let f3: Formula = "il risque de pleuvoir"
    let f4: Formula = "on est à la maison"

    let f6: Formula = "on fait des exercices"
    let f7: Formula = "on relit le cours"
    let f8: Formula = "le ciel est gris"
    let f9: Formula = "on est content"

    let j = (f1 => f2) && (f3 => !f2) && (!f4 => f2) && (f4 => (f6 && f7)) && (f8 => f3) && (f2 => (f6 && f9)) && (f1 || f8) |- f6
    
    print("\nProvable ? \(j.isProvable)")
}

// let a: Formula = "a"
// let b: Formula = "b"
// let f = a && b

// print(f)

// let booleanEvaluation = f.eval { (proposition) -> Bool in
//     switch proposition {
//         case "p": return true
//         case "q": return false
//         default : return false
//     }
// }
// print(booleanEvaluation)

// enum Fruit: BooleanAlgebra {

//     case apple, orange

//     static prefix func !(operand: Fruit) -> Fruit {
//         switch operand {
//         case .apple : return .orange
//         case .orange: return .apple
//         }
//     }

//     static func ||(lhs: Fruit, rhs: @autoclosure () throws -> Fruit) rethrows -> Fruit {
//         switch (lhs, try rhs()) {
//         case (.orange, .orange): return .orange
//         case (_ , _)           : return .apple
//         }
//     }

//     static func &&(lhs: Fruit, rhs: @autoclosure () throws -> Fruit) rethrows -> Fruit {
//         switch (lhs, try rhs()) {
//         case (.apple , .apple): return .apple
//         case (_, _)           : return .orange
//         }
//     }

// }

// let fruityEvaluation = f.eval { (proposition) -> Fruit in
//     switch proposition {
//         case "p": return .apple
//         case "q": return .orange
//         default : return .orange
//     }
// }
// print(fruityEvaluation)