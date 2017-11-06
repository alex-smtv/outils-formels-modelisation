import PetriKit

public extension PTNet {

    public func coverabilityGraph(from marking: CoverabilityMarking) -> CoverabilityGraph {
        // Write here the implementation of the coverability graph generation.

        // Note that CoverabilityMarking implements both `==` and `>` operators, meaning that you
        // may write `M > N` (with M and N instances of CoverabilityMarking) to check whether `M`
        // is a greater marking than `N`.

        // IMPORTANT: Your function MUST return a valid instance of CoverabilityGraph! The optional
        // print debug information you'll write in that function will NOT be taken into account to
        // evaluate your homework.

        // Root r
        let r = CoverabilityGraph(marking: marking)

        var nodesToVisit: [CoverabilityGraph] = [r]

        var num = 0
        // While there's a node to visit.
        while let node = nodesToVisit.popLast() {
            
            num += 1

            if num == 3 {
               // return r
            }

            var nextNodes: [PTTransition: CoverabilityMarking] = [:]

            // For each fireable transition, calculate next marking and save it.
            mainloop:
            for transition in transitions {

                // If for all preconditions of a transition there's at least one that can't be met, this transition isn't fireable. Jump to the next transition check.
                for arc in transition.preconditions {

                    let placeToken = node.marking[arc.place]!
                    let arcToken   = Token(integerLiteral: arc.tokens)

                    if placeToken < arcToken {
                        continue mainloop
                    }

                }

                // At this step of the code, the transition is fireable. Start constructing the marking after firing the transition.
                
                // Create var that will hold the new constructed marking
                var nextMarking = node.marking
                
                // For each preconditions, substract the arc value to the corresponding place
                for arc in transition.preconditions {
                    let placeToken = nextMarking[arc.place]!

                    switch placeToken {

                        case let .some(placeValue):
                            nextMarking[arc.place]! = Token(integerLiteral: placeValue - arc.tokens)
                        case .omega:
                            break

                    }

                }

                // For each postconditions, add the arc value to the corresponding place
                for arc in transition.postconditions {
                    let placeToken = nextMarking[arc.place]!

                    switch placeToken {
                        case let .some(placeValue):
                            nextMarking[arc.place]! = Token(integerLiteral: placeValue + arc.tokens)
                        case .omega:
                            break
                    }

                }

                nextNodes[transition] = nextMarking
            
            }

            // For each new nodes from previous fireable transitions
            for (transition, nextMarking) in nextNodes {

                //var alreadyExistInNetwork = false

                // for nodeNetwork in r {
                //     if nextMarking == nodeNetwork.marking {
                //         alreadyExistInNetwork = true
                //         node.successors[transition] = nodeNetwork
                //         break
                //     }
                // }

                //if !alreadyExistInNetwork {

                var omegaMarking = nextMarking

                omegaLoop:
                for nodeNetwork in r {
                    //print("\n Marking network: \(nodeNetwork.marking)\nVS New marking: \(omegaMarking) \n")
                    //print(omegaMarking > nodeNetwork.marking)
                    if omegaMarking > nodeNetwork.marking {
                        //print("Bigger marking !")
                        for successor in nodeNetwork {
                            if successor === node {
                                // put omega, break loops

                                //var omegaMarking = nextNode.marking

                                for (place, token) in omegaMarking {

                                    if nodeNetwork.marking[place]! < token {
                                        omegaMarking[place]! = Token.omega
                                        //print("omega happened!")
                                        //omegaMarking[place] = Token.omega
                                    }

                                }

                                //node.successors[transition] = CoverabilityGraph(marking: omegaMarking)
                                break omegaLoop
                            }
                        }
                    }
                }

                //print("omega result: \(omegaMarking)")


                    //print("\n\(node.marking)\n--(\(transition))--> \(nextNode.marking)\n")
                //} else {
                    //print("\n\(node.marking)\n--(\(transition))--> \(nextMarking)\n")
                //}

                var alreadyExistInNetwork = false

                for nodeNetwork in r {
                    if omegaMarking == nodeNetwork.marking {
                        //print("\n\(omegaMarking) == \(nodeNetwork.marking)")
                        alreadyExistInNetwork = true
                        node.successors[transition] = nodeNetwork
                        break
                    }
                }

                if !alreadyExistInNetwork {
                    let nextNode = CoverabilityGraph(marking: omegaMarking)
                    node.successors[transition] = nextNode
                    nodesToVisit.append(nextNode)
                    //print("\n\(omegaMarking) VS \(nextNode.marking)")
                }

                print("\n\(node.marking)\n--(\(transition))--> \(node.successors[transition]!.marking)\n")
            }

        }

        print("num = \(num)")
        return r
    }

}
