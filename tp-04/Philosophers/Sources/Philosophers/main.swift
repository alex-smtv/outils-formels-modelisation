import PetriKit
import PhilosophersLib

// QUESTION 1
do {
    print("-------------------------------------------------------------------------------------------------------")
    print("--- Question 1: How many markings are there in a lock free philosophers model with 5 philosophers ? ---")
    print("-------------------------------------------------------------------------------------------------------")
    print()

    let philosophers = lockFreePhilosophers(n: 5)

    if let boundModel = philosophers.markingGraph(from: philosophers.initialMarking!) {
        print(">> There is \(boundModel.count) possible markings.")
    } else {
        print("The model is unbound !")
    }

}

print()
print()

// QUESTION 2
do {
    print("-------------------------------------------------------------------------------------------------------")
    print("--- Question 2: How many markings are there in a lockable philosophers model with 5 philosophers ?  ---")
    print("-------------------------------------------------------------------------------------------------------")
    print()

    let philosophers = lockablePhilosophers(n: 5)

    if let boundModel = philosophers.markingGraph(from: philosophers.initialMarking!) {
        print(">> There is \(boundModel.count) possible markings.")
    } else {
        print("The model is unbound !")
    }

}

print()
print()

// QUESTION 3

// Make a little extension we'll use to compute the marking answering the question.
extension PredicateNet {

    public func getBlockableMarking() -> MarkingType? {

        if let initialNode = markingGraph(from: initialMarking!) {
            for node in initialNode {
                if node.successors.isEmpty { return node.marking }
            }
        }

        return nil
    }

}

do {
    print("---------------------------------------------------------------------------------------------------------------------------")
    print("--- Question 3: Example of a marking where the network is blocked in a lockable philosophers model with 5 philosophers. ---")
    print("---------------------------------------------------------------------------------------------------------------------------")
    print()

    let philosophers = lockablePhilosophers(n: 5)

    if let blockableMarking = philosophers.getBlockableMarking() {
        print("An example of such marking is : \(blockableMarking)")
    } else {
        print("An error occured. This should not happen.")
        print()

        // Calculated after several tests.
        var blockableMarking: PredicateNet<PhiloType>.MarkingType = [:]
        blockableMarking["eating"]   = []
        blockableMarking["waiting"]  = [PhiloType.philosopher(0), PhiloType.philosopher(1), PhiloType.philosopher(2), PhiloType.philosopher(3), PhiloType.philosopher(4)]
        blockableMarking["thinking"] = []
        blockableMarking["forks"]    = []

        print("The application failed to compute an example of such marking. In normal condition, this is one marking answering the quetsion: ")
        print(blockableMarking)
    }
    
}