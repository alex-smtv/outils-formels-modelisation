import PetriKit
import SmokersLib

// Instantiate the model.
let model = createModel()

// Retrieve places model.
guard let r  = model.places.first(where: { $0.name == "r" }),
      let p  = model.places.first(where: { $0.name == "p" }),
      let t  = model.places.first(where: { $0.name == "t" }),
      let m  = model.places.first(where: { $0.name == "m" }),
      let w1 = model.places.first(where: { $0.name == "w1" }),
      let s1 = model.places.first(where: { $0.name == "s1" }),
      let w2 = model.places.first(where: { $0.name == "w2" }),
      let s2 = model.places.first(where: { $0.name == "s2" }),
      let w3 = model.places.first(where: { $0.name == "w3" }),
      let s3 = model.places.first(where: { $0.name == "s3" })
else {
    fatalError("invalid model")
}

// Create the initial marking.
let initialMarking: PTMarking = [r: 1, p: 0, t: 0, m: 0, w1: 1, s1: 0, w2: 1, s2: 0, w3: 1, s3: 0]

// Create the marking graph (if possible).
if let markingGraph = model.markingGraph(from: initialMarking) {
    // Write here the code necessary to answer questions of Exercise 4.

    var nodesToVisit     : [MarkingGraph] = [markingGraph]
    var allMarkingsFound : [PTMarking]    = []

    // We'll navigate through the graph to catch all unique markings
    while !nodesToVisit.isEmpty {

        let node = nodesToVisit.removeFirst()
        allMarkingsFound.append(node.marking)

        // Check for each successor node
        for nextNode in node.successors.values {

            // Do something only if the successor marking isn't one we already found AND if the successor marking isn't one from the nodes planned to visit
            if !allMarkingsFound.contains(where: { $0 == nextNode.marking }) && nodesToVisit.first(where: { $0.marking == nextNode.marking }) == nil {
                nodesToVisit.append(nextNode)
            }

        }

    }

    print("Question 4.1) We found \(allMarkingsFound.count) unique markings. In consequence there is \(allMarkingsFound.count) different states in our network.")
    print()

    var existTwoSmokerSmoking    = false
    var existTwoOfSameIngredient = false

    // Analyse each marking for answering the questions
    for marking in allMarkingsFound {

        // Get tokens from smoking smokers
        let s1 = marking.first(where: { $0.key.name == "s1" })!.value
        let s2 = marking.first(where: { $0.key.name == "s2" })!.value
        let s3 = marking.first(where: { $0.key.name == "s3" })!.value

        // Get tokens from ingredients
        let p = marking.first(where: { $0.key.name == "p" })!.value
        let t = marking.first(where: { $0.key.name == "t" })!.value
        let m = marking.first(where: { $0.key.name == "m" })!.value

        // If at least two smoking smokers is found
        if !existTwoSmokerSmoking && ( (s1 == 1 && s2 == 1) || (s1 == 1 && s3 == 1) || (s2 == 1 && s3 == 1) ) {
            existTwoSmokerSmoking = true
            print("Question 4.2) At least one occurrence of two different smokers smoking at the same time has been found. So yes, it's possible that two different smokers are smoking at the same time.")
            print("  - This is the matching marking answering the question: \(marking)")
            print()
        }

        // If at least one ingredient with a quantity of 2 is found
        if !existTwoOfSameIngredient && (p == 2 || t == 2 || m == 2) {
            existTwoOfSameIngredient = true
            print("Question 4.3) The answer to the question is no: it's not possible to have two quantity of the same ingredient on the table. Unfortunately the application found a scenario of this happening: an unwanted error is present.")
            print("  - This is the (false) matching marking to the question: \(marking)")
            print()
        }

    }

    if !existTwoSmokerSmoking {
        print("Question 4.2) The answer to the question is yes: two different smokers can be smoking at the same time. Unfortunately the application didn't find one such scenario: an unwanted error is present.")
        print()
    }

    if !existTwoOfSameIngredient {
        print("Question 4.3) From all the ingredients none is found twice on the table. So no, it's not possible to have two quantity of the same ingredient on the table.")
        print()
    }

    print("End of the demonstration.")
}
