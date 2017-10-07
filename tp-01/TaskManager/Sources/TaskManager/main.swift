import TaskManagerLib

let taskManager = createTaskManager()

print("##################################################################")
print("### An example of sequence that leads to the described problem ###")
print("##################################################################")
print()

// * Taking back our places and transitions from the task manager

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

// Simulation of the problem
var m = create.fire(from: [taskPool: 0, processPool: 0, inProgress: 0]) ; print("\(m!)  // fire create")
m = spawn  .fire(from: m!) ; print("\(m!)  // fire spawn")
m = exec   .fire(from: m!) ; print("\(m!)  // fire exec")
m = spawn  .fire(from: m!) ; print("\(m!)  // fire spawn")
m = exec   .fire(from: m!) ; print("\(m!)  // fire exec")
m = success.fire(from: m!) ; print("\(m!)  // fire success")

print()
print(">> Problem: remaining process will never be killed. See below")
print()

/*  Explanation
  0. Initial state: create one task
  1. One new process is available
  2. Execute task with the available process
  3. While processing, another process is released
  4. Consequently, the new released process will try to execute the previous task that 
     is still being processed by the first process
  5. On success, one task is taken off from the task pool and one process is killed: 
     the other process remains in the "in progress" place

  Problem: from now on the remaining process will never be killed.
*/

// * Additional output to illustrate some case where the process can not be killed

// Illustration when a new task succed
var mIS = create .fire(from: m!)
mIS = spawn  .fire(from: mIS!)
mIS = exec   .fire(from: mIS!)
mIS = success.fire(from: mIS!)
print("Final marking when a new task succeed: \(mIS!)")
print()

// Illustration when a new task fails
var mIF = create .fire(from: m!)
mIF = spawn  .fire(from: mIF!)
mIF = exec   .fire(from: mIF!)
mIF = fail   .fire(from: mIF!)
print("Final marking when a new task fails   : \(mIF!)")

mIF = spawn  .fire(from: mIF!)
print("     |--> Then a new process spawns   : \(mIF!)")

mIF = exec   .fire(from: mIF!)
mIF = success.fire(from: mIF!)
print("     |--> And finally the task succeed: \(mIF!)")

// ===========================================================================

let correctTaskManager = createCorrectTaskManager()

// Show here that you corrected the problem.
// For instance:
//     let m1 = create.fire(from: [taskPool: 0, processPool: 0, inProgress: 0])
//     let m2 = spawn.fire(from: m1!)
//     ...
