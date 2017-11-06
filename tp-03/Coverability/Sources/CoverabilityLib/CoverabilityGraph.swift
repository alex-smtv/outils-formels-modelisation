import PetriKit

public class CoverabilityGraph {

    public init(
        marking: CoverabilityMarking, successors: [PTTransition: CoverabilityGraph] = [:])
    {
        self.marking    = marking
        self.successors = successors
    }

    public let marking   : CoverabilityMarking
    public var successors: [PTTransition: CoverabilityGraph]

    /// The number of nodes in the graph.
    public var count: Int {
        var seen: [CoverabilityGraph] = []
        var toCheck = [self]

        while let node = toCheck.popLast() {
            seen.append(node)
            for (_, successor) in node.successors {

                // /!\ REMARK /!\ for assignment correction: the check of whether the successor node is contained in the array of future nodes to be visited was missing
                //                                           and it's an important checking for proper counting
                if !seen.contains(where: { $0 === successor }) && !toCheck.contains(where: { $0 === successor }) {
                    toCheck.append(successor)
                }
            }
        }
        
        return seen.count
    }

}

extension CoverabilityGraph: Sequence {

    public func makeIterator() -> AnyIterator<CoverabilityGraph> {
        var seen: [CoverabilityGraph] = []
        var toCheck = [self]

        return AnyIterator {
            guard let node = toCheck.popLast() else {
                return nil
            }

            let unvisited = node.successors.values.flatMap { successor in
                return seen.contains(where: { $0 === successor })
                    ? nil
                    : successor
            }

            seen.append(contentsOf: unvisited)
            toCheck.append(contentsOf: unvisited)

            return node
        }
    }

}
