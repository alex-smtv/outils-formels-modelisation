import PetriKit

public func createTaskManager() -> PTNet {
    // Places
    let taskPool    = PTPlace(named: "taskPool")
    let processPool = PTPlace(named: "processPool")
    let inProgress  = PTPlace(named: "inProgress")

    // Transitions
    let create      = PTTransition(
        named          : "create",
        preconditions  : [],
        postconditions : [PTArc(place: taskPool)])
    let spawn       = PTTransition(
        named          : "spawn",
        preconditions  : [],
        postconditions : [PTArc(place: processPool)])
    let success     = PTTransition(
        named          : "success",
        preconditions  : [PTArc(place: taskPool), PTArc(place: inProgress)],
        postconditions : [])
    let exec       = PTTransition(
        named          : "exec",
        preconditions  : [PTArc(place: taskPool), PTArc(place: processPool)],
        postconditions : [PTArc(place: taskPool), PTArc(place: inProgress)])
    let fail        = PTTransition(
        named          : "fail",
        preconditions  : [PTArc(place: inProgress)],
        postconditions : [])

    // P/T-net
    return PTNet(
        places: [taskPool, processPool, inProgress],
        transitions: [create, spawn, success, exec, fail])
}


// The idea of the corrected task manager is to prevent two process taking the same task.
public func createCorrectTaskManager() -> PTNet {
    // Places
    let taskPool    = PTPlace(named: "taskPool")
    let processPool = PTPlace(named: "processPool")
    let inProgress  = PTPlace(named: "inProgress")

    // First modification, a new place (scroll down for a detailed explanation)
    let processPass = PTPlace(named: "processPass")

    // Transitions
    let create      = PTTransition(
        named          : "create",
        preconditions  : [],
        // Second modification, a new post arc (scroll down for a detailed explanation)
        postconditions : [PTArc(place: taskPool), PTArc(place: processPass)])
    let spawn       = PTTransition(
        named          : "spawn",
        preconditions  : [],
        postconditions : [PTArc(place: processPool)])
    let success     = PTTransition(
        named          : "success",
        preconditions  : [PTArc(place: taskPool), PTArc(place: inProgress)],
        postconditions : [])
    let exec       = PTTransition(
        named          : "exec",
        // Third modification, a new pre arc (scroll down for a detailed explanation)
        preconditions  : [PTArc(place: taskPool), PTArc(place: processPool), PTArc(place: processPass)],
        postconditions : [PTArc(place: taskPool), PTArc(place: inProgress)])
    let fail        = PTTransition(
        named          : "fail",
        // Fourth modification, a new post arc (scroll down for a detailed explanation)
        preconditions  : [PTArc(place: inProgress)],
        postconditions : [PTArc(place: processPass)])

    // P/T-net
    return PTNet(
        // Fifth modification, add the new place to the set (scroll down for a detailed explanation)
        places: [taskPool, processPool, inProgress, processPass],
        transitions: [create, spawn, success, exec, fail])

    /*  Detailed Explanation:
    
        As stated at the beginning of the function, the idea of the corrected task manager is to prevent two process taking the same task.
        
        In this respect, we try to introduce a concept where the process needs a pass on top of the previous constraints in order to 
        execute one task. Without this pass, a process remains in the process pool.

        This concept is implemented in the following way:
            - A new place named "processPass" is created. This place is responsible for getting passes and to consume them.
            - The processPass gets one pass (resource) each time the create transition is fired (arc from create to processPass). 
            - The processPass is connected to the exec transition as an additional pre condition (arc from processPass to exec).
              In some way, a pass is bound to a task and (only) one process can "take" the pass.
            - To make the system works in both success and fail scenario, we need to get back one pass when one execution fails.
              This is made by connecting the fail transition to processPass (arc from fail to processPass).
    */
}
