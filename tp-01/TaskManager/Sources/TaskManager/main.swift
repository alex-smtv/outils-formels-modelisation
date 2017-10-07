import TaskManagerLib

let taskManager = createTaskManager()

print()
print("##################################################################")
print("### An example of sequence that leads to the described problem ###")
print("##################################################################")
print()

// * Taking back our places and transitions from the task manager 
// (using var because we'll re-initalize them in the correct task manager)

// Places
var taskPool    = taskManager.places.filter { $0.name == "taskPool"    }[0]
var processPool = taskManager.places.filter { $0.name == "processPool" }[0]
var inProgress  = taskManager.places.filter { $0.name == "inProgress"  }[0]

// Transitions
var create  = taskManager.transitions.filter { $0.name == "create"  }[0]
var spawn   = taskManager.transitions.filter { $0.name == "spawn"   }[0]
var success = taskManager.transitions.filter { $0.name == "success" }[0]
var exec    = taskManager.transitions.filter { $0.name == "exec"    }[0]
var fail    = taskManager.transitions.filter { $0.name == "fail"    }[0]

// Simulation of the problem
var m = create.fire(from: [taskPool: 0, processPool: 0, inProgress: 0]) ; print("\(m!)  // fire create")
m = spawn  .fire(from: m!) ; print("\(m!)  // fire spawn")
m = exec   .fire(from: m!) ; print("\(m!)  // fire exec")
m = spawn  .fire(from: m!) ; print("\(m!)  // fire spawn")
m = exec   .fire(from: m!) ; print("\(m!)  // fire exec")
m = success.fire(from: m!) ; print("\(m!)  // fire success")

print()
print(">> Problem: remaining process will never be killed. See below.")
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

print()
print()
print("##################################################################")
print("###          Proposition of a corrected task manager           ###")
print("##################################################################")
print()

// * Taking back our places and transitions from the task manager

// Places
taskPool    = correctTaskManager.places.filter { $0.name == "taskPool"    }[0]
processPool = correctTaskManager.places.filter { $0.name == "processPool" }[0]
inProgress  = correctTaskManager.places.filter { $0.name == "inProgress"  }[0]
let processPass = correctTaskManager.places.filter { $0.name == "processPass" }[0]

// Transitions
create  = correctTaskManager.transitions.filter { $0.name == "create"  }[0]
spawn   = correctTaskManager.transitions.filter { $0.name == "spawn"   }[0]
success = correctTaskManager.transitions.filter { $0.name == "success" }[0]
exec    = correctTaskManager.transitions.filter { $0.name == "exec"    }[0]
fail    = correctTaskManager.transitions.filter { $0.name == "fail"    }[0]

// Simulation of resolution of the problem
m = create  .fire(from: [taskPool: 0, processPool: 0, inProgress: 0, processPass: 0]) ; print("\(m!)  // fire create")
m = spawn   .fire(from: m!) ; print("\(m!)  // fire spawn")
m = exec    .fire(from: m!) ; print("\(m!)  // fire exec")
m = spawn   .fire(from: m!) ; print("\(m!)  // fire spawn")
let x = exec.fire(from: m!)

if x != nil {
    print("\(m!)  // fire exec (review code: this should not happen, end of execution here)")
} else {
    print()
    print("We tried to fire exec, but it was impossible. Indeed the pre conditions are not met!")
    print()
    m = success.fire(from: m!) ; print("\(m!)  // fire success")

    print()
    print("The second process that was spawned remains in the process pool. The behavior is now correct.")
    print("Let's quickly test that a failed task give us one process pass back.")
    print()

    // From previous testing, there's already one process in the pool
    m = create.fire(from: m!) ; print("\(m!)  // fire create")
    m = exec  .fire(from: m!) ; print("\(m!)  // fire exec")
    m = fail  .fire(from: m!) ; print("\(m!)  // fire fail")

    print()
    print("We got our process pass back, the behavior is also correct in this scenario.")
    print()
    print("End of the demonstration.")
}