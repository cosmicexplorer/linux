CS 281 Project: Robust CFS Logging
==================================

With Anna Hwang (hwangas) and Danny McClanahan (mccland). Project located at https://github.com/dannyannaleggo/linux-cfs-logger.

----------------------
# Overview

----------------------

## Background

The Linux operating system typically implements scheduling of most userspace processes using a Completely Fair Scheduler (CFS). The CFS implements O(log(n)) process scheduling using a red-black tree (rb tree), updated each context switch to determine the currently running process. This mechanism is intended to keep CPU usage equal across different userspace processes, and across different users.

## Goals

Implement a system for logging the contents of the CFS red-black tree over time. Create interface from userspace code to query this data. Userspace program will display some analysis and/or visualization of the scheduler's internals.

----------------------
# Sections

----------------------

## Kernel Internals

- Add data structure in kernel to log CFS rb tree
  - Figure out best way to represent this structure (essentially a log buffer). Is there a compact way to represent it? Traversing or cloning the entire RB tree is far too computationally intensive to perform each context switch.
- Update this structure each context switch
  - Important to reduce computation done during interrupt handling
- Kernel thread which periodically checks how many context switches have been logged
  - Either increase size of buffer, trash older buffer entries, etc.
  - Keep time/space bounded; this is kernel code, after all
  - Also turn compact representation of rb tree changes into more verbose form? See below.

## Kernel Interaction

- Add syscall to dump rb tree changes into virtual file
- Output results to procfs
- Figure out what sort of format is appropriate
  - JSON is easily parsable by a userspace program and would be able to adequately represent the rb tree. However, it may be better to log a compact representation to proc and then provide a method (library, executable) to transform to JSON.

## Userspace Program

- Minimal viable product will just display relative cpu usage per process (kind of like top/ps)
  - Can be performed by examining how often a process is at the root of the tree (currently scheduled)
- More advanced version will take advantage of the greater scheduler data provided
  - visually display rb tree
  - visually display realtime histogram of running processes
  - allow for "pausing" output and analyzing in depth
  - show I/O-heavy vs CPU-heavy processes
  - probably like a ton of other cool stuff

----------------------
# Work Breakdown

----------------------

## Danny

- Modify context switcher to add data structure logging rb tree
- Add kernel thread to handle log buffer
- Add syscall to dump output to proc
- Negotiate with Anna about best format for proc output
  - Have to make it easy for userspace program to run syscall and get some form of output representing recent states of rb tree

## Anna

- Parse proc output (into JSON?)
- Write userspace program based on output
  - Terminal application? GUI?
    - Visualization possible in both, but may be easier one way or another
      - ASCII or ncurses for terminal output
  - Which language?
    - Java, Python, Javascript, ...
  - How to incorporate kernel interaction?
    - Most languages don't offer native syscall functionality except for C
      - Or if it exists, it's annoying to use
    - Can use foreign function interface available for language
    - Can make auxiliary executable just for calling syscall and relaying data
      - Can use IPC from auxiliary syscall executable in C to main userspace program in higher-level language

----------------------
# Milestones

----------------------

# March 30

- Have agreed on intermediate representation of scheduler tree in procfs
- Have decided on framework for display results (GUI/terminal, which language to use)
- Have demonstrated proof of concept for pipeline of rb tree data to procfs (not necessarily usable data, just some data)

# April 15

- Have implemented complete pipeline of rb tree data to procfs, although may not be fully robust
- Userspace program can display some sort of burndown data for processes scheduled

# April 28: Due Date

- full kernel and userspace segments completed

----------------------
# Instructor Comments on Design

----------------------

- output to binary, have other program interpreting
- don't add syscall, not required
- just have kthread outputting constantly to some file globally available in procfs
  - because procfs is a virtual file system, it actually just calls a function whenever a read is instigated on a file
  - therefore no memory concerns
- use another node in procfs to turn on/off logging (write 1/0 to switch on/off)
- forensic analysis: offline instead of realtime
- consider having per-process access to proc
- only attempt to add functionality in userspace if we're confident we can get that data from the kernel
- have quite clearly defined output
- rtfm
- try to keep everything that can change inside a kernel module
- keep only entry point as function pointer inside scheduler
- can have mixture of both online/offline analysis

----------------------
# Resources

----------------------

- http://www.ibm.com/developerworks/library/l-completely-fair-scheduler/
  - good overhead description of cfs, with some code references

----------------------
# Product

----------------------

- online mode and offline mode
- offline mode is set to run for a certain period of time and display the rb tree at each context switch during that period of time
  - collect aggregate and over-time stats (a moving average of which processes are running at which heights on the rb tree, for example)
- online mode (more limited functionality):
  - can run queries on current state of rb tree
