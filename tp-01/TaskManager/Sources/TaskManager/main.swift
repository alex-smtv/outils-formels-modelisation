import TaskManagerLib

let taskManager = createTaskManager()

// Show here an example of sequence that leads to the described problem.
// For instance:
//     let m1 = create.fire(from: [taskPool: 0, processPool: 0, inProgress: 0])
//     let m2 = spawn.fire(from: m1!)
//     ...

// REMARK: to make our simulation we're taking back our places and transitions from the task manager 
//         && we're putting them into vars (and not into lets, because our vars will be initialized a second time at the corrected version)

print("##################################################################")
print("### An example of sequence that leads to the described problem ###")
print("##################################################################")
print()

// Places
let taskPool    = taskManager.places.filter { $0.name == "taskPool"    }[0]
let processPool = taskManager.places.filter { $0.name == "processPool" }[0]
let inProgress  = taskManager.places.filter { $0.name == "inProgress"  }[0]

// Transitions
let create  = taskManager.transitions.filter { $0.name == "create"  }[0]
let spawn   = taskManager.transitions.filter { $0.name == "spawn"   }[0]
let success = taskManager.transitions.filter { $0.name == "success" }[0]
let exec    = taskManager.transitions.filter { $0.name == "exec"    }[0]
let fail    = taskManager.transitions.filter { $0.name == "fail"    }[0]

// Initial state: create one task
let m1 = create.fire(from: [taskPool: 0, processPool: 0, inProgress: 0])
print("m1: \(m1!)")

// One new process available
let m2 = spawn.fire(from: m1!)
print("m2: \(m2!)")

// Execute task with the available process
let m3 = exec.fire(from: m2!)
print("m3: \(m3!)")

// While processing, another process is released
let m4 = spawn.fire(from: m3!)
print("m4: \(m4!)")

// Consequently the new released process will execute the previous task that is still being independently processed in the first process
let m5 = exec.fire(from: m4!)
print("m5: \(m5!)")

// On success, one task is taken off from the task pool and one process is killed: the other process remains in "in progress" place
let m6 = success.fire(from: m5!)
print("m6: \(m6!)")

// PROBLEM: from now on, the remaining process will never be killed
print("\n>> Problem: remaining process will never be killed.\n")

// Illustration when a new task succed
let mIS1 = create .fire(from: m6!)
let mIS2 = spawn  .fire(from: mIS1!)
let mIS3 = exec   .fire(from: mIS2!)
let mIS4 = success.fire(from: mIS3!)
print("Final marking when a new task succeed: \(mIS4!)")
print()

// Illustration when a new task fails
let mIF1 = create .fire(from: m6!)
let mIF2 = spawn  .fire(from: mIF1!)
let mIF3 = exec   .fire(from: mIF2!)
let mIF4 = fail   .fire(from: mIF3!)
print("Final marking when a new task fails   : \(mIF4!)")

let mIF5 = spawn  .fire(from: mIF4!)
print("     |--> Then a new process spawns   : \(mIF5!)")

let mIF6 = exec   .fire(from: mIF5!)
let mIF7 = success.fire(from: mIF6!)
print("     |--> And finally the task succeed: \(mIF7!)")

let correctTaskManager = createCorrectTaskManager()

// Show here that you corrected the problem.
// For instance:
//     let m1 = create.fire(from: [taskPool: 0, processPool: 0, inProgress: 0])
//     let m2 = spawn.fire(from: m1!)
//     ...
