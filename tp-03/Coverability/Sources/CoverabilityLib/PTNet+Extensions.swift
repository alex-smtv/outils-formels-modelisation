import PetriKit

public extension PTNet {

    public func coverabilityGraph(from marking: CoverabilityMarking) -> CoverabilityGraph {

        let root = CoverabilityGraph(marking: marking)
        var nodesToVisit: [CoverabilityGraph] = [root]

        while let node = nodesToVisit.popLast() {

            // For each fireable transition from the current node.
            for (transition, nextMarking) in fireableTransitions(from: node.marking, with: transitions) {

                // Save the marking after evaluating if omega tokens should be added.
                let finalMarking = evaluateOmega(newMarking: nextMarking, parentNode: node, rootGraph: root)

                // If the marking already exist in the graph, then use the corresponding existing node for the successor.
                if let nodeAlreadyExist = root.first(where: { $0.marking == finalMarking }) {
                    node.successors[transition] = nodeAlreadyExist
                } else {

                    // Else construct a new node from the marking and add it to the successors list.
                    let nextNode = CoverabilityGraph(marking: finalMarking)
                    node.successors[transition] = nextNode

                    // Add the new node to list of nodes to be visited.
                    nodesToVisit.append(nextNode)

                }

                // Uncomment the following line for printing debug.
                // print("\n\(node.marking)\n--(\(transition))--> \(node.successors[transition]!.marking)\n")
            }

        }

        return root
    }

}

/**
 Determine all fireable transitions from a marking with a set of transitions. In addition, the next marking is calculated for all fireable transitions.
*/
public func fireableTransitions(from marking: CoverabilityMarking, with transitions: Set<PTTransition>) -> [PTTransition: CoverabilityMarking] {

    // Holds the list of fireable transitions with the corresponding calculated next marking.
    var nextNodes: [PTTransition: CoverabilityMarking] = [:]

    transitionsLoop:
    for transition in transitions {

        // Check all preconditions of a transition to determine if it's fireable. If not, ignore the rest and jump to the next transition.
        for arc in transition.preconditions {

            let placeToken = marking[arc.place]!
            let arcToken   = Token(integerLiteral: arc.tokens)

            // If there's a place with a value less than his corresponding arc, then it's not fireable.
            if placeToken < arcToken {
                continue transitionsLoop
            }

        }

        // At this step of the code, the transition is fireable. Start constructing the next marking.
        var nextMarking = marking

        // For each preconditions, substract the arc value to the corresponding place.
        for arc in transition.preconditions {
            let placeToken = nextMarking[arc.place]!

            switch placeToken {

                case let .some(placeValue):
                    nextMarking[arc.place]! = Token(integerLiteral: placeValue - arc.tokens)
                case .omega:
                    break

            }

        }

        // For each postconditions, add the arc value to the corresponding place.
        for arc in transition.postconditions {
            let placeToken = nextMarking[arc.place]!

            switch placeToken {

                case let .some(placeValue):
                    nextMarking[arc.place]! = Token(integerLiteral: placeValue + arc.tokens)
                case .omega:
                    break

            }

        }

        // Add the fireable transition found with the calculated next marking.
        nextNodes[transition] = nextMarking
    }

    return nextNodes
}

/**
 Evaluate a new marking and add omega tokens if necessary. For this we need his direct parent and the root graph.
*/
public func evaluateOmega(newMarking: CoverabilityMarking, parentNode: CoverabilityGraph, rootGraph: CoverabilityGraph) -> CoverabilityMarking {

    // Gather all nodes which satisfy the condition : M' > M  (new marking > any previous marking).
    let candidates = rootGraph.filter { newMarking > $0.marking }
    
    // Holds the final marking that will be returned by the function. The marking may be modified with omega value if necessary.
    var finalMarking = newMarking
    
    // Now we need to determine if there's a valid candidate, meaning a candidate which is an ancestor from the parent node.
    for candidate in candidates {

        // Navigate through the candidate's successors until finding a successor which is the parent node, if found then do something.
        if candidate.first(where: { $0 === parentNode }) != nil {

            // For each place from the final marking.
            for (place, token) in finalMarking {

                // Add an omega token if the candidate's token value is lower.
                if candidate.marking[place]! < token {
                    finalMarking[place]! = Token.omega
                }

            }

            break
        }
    }

    return finalMarking
}