extension PredicateNet {

    /// Returns the marking graph of a bounded predicate net.
    public func markingGraph(from marking: MarkingType) -> PredicateMarkingNode<T>? {
        // Write your code here ...

        // Note that I created the two static methods `equals(_:_:)` and `greater(_:_:)` to help
        // you compare predicate markings. You can use them as the following:
        //
        //     PredicateNet.equals(someMarking, someOtherMarking)
        //     PredicateNet.greater(someMarking, someOtherMarking)
        //
        // You may use these methods to check if you've already visited a marking, or if the model
        // is unbounded.

        let initialNode = PredicateMarkingNode(marking: marking)        
        var toVisit: [PredicateMarkingNode<T>] = [initialNode]

        while let node = toVisit.popLast() {

            // fireable var will hold all possible fireable transitions and will keep information of which bindings make a transition fireable.
            var fireable: [PredicateTransition<T>: [PredicateTransition<T>.Binding]] = [:]

            // Iterate through all transitions to find which one is fireable with which bindings.
            for transition in self.transitions {
                let bindings = transition.fireableBingings(from: node.marking)

                if bindings.count > 0 {
                    fireable[transition] = bindings
                }
            }

            // If no transition is fireable from the current node, jump to the next iteration.
            guard !fireable.isEmpty else { continue }

            // Now iterate through each known fireable transitions with their appropriate bindings and calculate the successors of the current node.
            for (transition, bindings) in fireable {

                // bindingMap var will hold all possible mapping of a binding to a successor node. This PredicateBindingMap will be associated to the current transition later.
                var bindingMap = PredicateBindingMap<T>()

                // For each valid binding, determine the successor node.
                for binding in bindings {
                    
                    let newMarking = transition.fire(from: node.marking, with: binding)!
                    var successorNode: PredicateMarkingNode<T>?

                    // Iterate through the petri net being constructed to determine if the new successor already exist.
                    for createdNode in initialNode {
                        if PredicateNet.equals(newMarking, createdNode.marking) {
                            
                            // Successor already exist, save it and break the loop.
                            successorNode = createdNode
                            break
                            
                        } else if PredicateNet.greater(newMarking, createdNode.marking) {
                            // The model is unbound, stop everything and return nil.
                            return nil
                        }
                    }

                    // If the successor node already exist, map the binding to this successor node.
                    if let successorAlreadyExist = successorNode {
                        bindingMap[binding] = successorAlreadyExist
                    } 
                    // Else map the binding to a newly created successor node and add that node to the list of nodes to be visited.
                    else {
                        let successor = PredicateMarkingNode(marking: newMarking)

                        bindingMap[binding] = successor
                        toVisit.append( successor )
                    }

                }

                // For the current fireable transition, add all possible successors to the current node.
                node.successors[transition] = bindingMap
            }

        }

        return initialNode
    }

    // MARK: Internals
    
    private static func equals(_ lhs: MarkingType, _ rhs: MarkingType) -> Bool {
        guard lhs.keys == rhs.keys else { return false }
        for (place, tokens) in lhs {
            guard tokens.count == rhs[place]!.count else { return false }
            for t in tokens {
                guard tokens.filter({ $0 == t }).count == rhs[place]!.filter({ $0 == t }).count
                    else {
                        return false
                }
            }
        }
        return true
    }

    private static func greater(_ lhs: MarkingType, _ rhs: MarkingType) -> Bool {
        guard lhs.keys == rhs.keys else { return false }

        var hasGreater = false
        for (place, tokens) in lhs {
            guard tokens.count >= rhs[place]!.count else { return false }
            hasGreater = hasGreater || (tokens.count > rhs[place]!.count)
            for t in rhs[place]! {
                guard tokens.filter({ $0 == t }).count >= rhs[place]!.filter({ $0 == t }).count
                    else {
                        return false
                }
            }
        }
        return hasGreater
    }

}

/// The type of nodes in the marking graph of predicate nets.
public class PredicateMarkingNode<T: Equatable>: Sequence {

    public init(
        marking   : PredicateNet<T>.MarkingType,
        successors: [PredicateTransition<T>: PredicateBindingMap<T>] = [:])
    {
        self.marking    = marking
        self.successors = successors
    }

    public func makeIterator() -> AnyIterator<PredicateMarkingNode> {
        var visited = [self]
        var toVisit = [self]

        return AnyIterator {
            guard let currentNode = toVisit.popLast() else {
                return nil
            }

            var unvisited: [PredicateMarkingNode] = []
            for (_, successorsByBinding) in currentNode.successors {
                for (_, successor) in successorsByBinding {
                    if !visited.contains(where: { $0 === successor }) {
                        unvisited.append(successor)
                    }
                }
            }

            visited.append(contentsOf: unvisited)
            toVisit.append(contentsOf: unvisited)

            return currentNode
        }
    }

    public var count: Int {
        var result = 0
        for _ in self {
            result += 1
        }
        return result
    }

    public let marking: PredicateNet<T>.MarkingType

    /// The successors of this node.
    public var successors: [PredicateTransition<T>: PredicateBindingMap<T>]

}

/// The type of the mapping `(Binding) ->  PredicateMarkingNode`.
///
/// - Note: Until Conditional conformances (SE-0143) is implemented, we can't make `Binding`
///   conform to `Hashable`, and therefore can't use Swift's dictionaries to implement this
///   mapping. Hence we'll wrap this in a tuple list until then.
public struct PredicateBindingMap<T: Equatable>: Collection {

    public typealias Key     = PredicateTransition<T>.Binding
    public typealias Value   = PredicateMarkingNode<T>
    public typealias Element = (key: Key, value: Value)

    public var startIndex: Int {
        return self.storage.startIndex
    }

    public var endIndex: Int {
        return self.storage.endIndex
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    public subscript(index: Int) -> Element {
        return self.storage[index]
    }

    public subscript(key: Key) -> Value? {
        get {
            return self.storage.first(where: { $0.0 == key })?.value
        }

        set {
            let index = self.storage.index(where: { $0.0 == key })
            if let value = newValue {
                if index != nil {
                    self.storage[index!] = (key, value)
                } else {
                    self.storage.append((key, value))
                }
            } else if index != nil {
                self.storage.remove(at: index!)
            }
        }
    }

    // MARK: Internals

    private var storage: [(key: Key, value: Value)]

}

extension PredicateBindingMap: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: ([Variable: T], PredicateMarkingNode<T>)...) {
        self.storage = elements
    }

}
