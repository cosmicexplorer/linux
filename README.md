CS 281 Project: Robust CFS Logging
==================================

With Anna Hwang and Danny McClanahan. Project located at https://github.com/cosmicexplorer/linux-cfs-logger.

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
