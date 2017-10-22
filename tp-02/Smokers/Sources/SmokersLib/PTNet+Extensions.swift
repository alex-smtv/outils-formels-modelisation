import PetriKit

public class MarkingGraph {

    public let marking   : PTMarking
    public var successors: [PTTransition: MarkingGraph]

    public init(marking: PTMarking, successors: [PTTransition: MarkingGraph] = [:]) {
        self.marking    = marking
        self.successors = successors
    }

}

public extension PTNet {

    public func markingGraph(from marking: PTMarking) -> MarkingGraph? {
        // Write here the implementation of the marking graph generation.

        let firstNode = MarkingGraph(marking: marking)

        var nodesToVisit : [MarkingGraph] = [firstNode]
        var nodesVisited : [MarkingGraph] = []

        while !nodesToVisit.isEmpty {

            let node = nodesToVisit.removeFirst()
            nodesVisited.append(node)

            // Check for each transition which one is fireable from the current node marking
            for transition in transitions {

                if let newMarking = transition.fire(from: node.marking) {
                    
                    // If the transition is firable, we're going to determine which node will be the successor
                    var nextNode: MarkingGraph? = nil

                    // Check if the new marking is already one of the node already visited or to be visited and if it's the case, get that node
                    if let nodeAlreadyVisited = nodesVisited.first(where: { $0.marking == newMarking }) {
                        nextNode = nodeAlreadyVisited
                    } 
                    else if let nodeToBeVisited = nodesToVisit.first(where: { $0.marking == newMarking }) {
                        nextNode = nodeToBeVisited
                    }
                    
                    // If no existing node corresponding to the new marking is found, create the node
                    if (nextNode == nil) {
                        nextNode = MarkingGraph(marking: newMarking)
                        nodesToVisit.append(nextNode!)
                    }
                    
                    // Add the next node to the list of successors 
                    node.successors[transition] = nextNode
                }

            }

        }

        return firstNode
    }

}
