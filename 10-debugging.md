# Debugging <!-- omit in toc -->

This is a chapter about debugging tools, best practices and how we debug iOS apps in Uptech 🐞

## Debugging iOS apps <!-- omit in toc -->

- [Best practices](#1-best-practices)
- [LLDB](#2-LLDB)
  - Breakpoints
  - Expressions
- [Xcode Instruments](#3-Xcode-Instruments)
  - View debugger
  - Time profiler
  - Allocations
  - Memory debugger
  - Battery
- [Logging](#4-Logging)
- [Useful tools](#5-Useful-tools)

 

### 1. Best Practices

Something about this

### 2. LLDB

LLDB

#### Breakpoints

#### Expressions



### 3. Xcode Instruments

Xcode instruments is a set of powerful tools to use **while** developing apps for iOS/macOS. Although we were tempted to dive deep into every one of them, not all of them are necessary on a day-to-day basis. Instead, lets cover ones that should be used to test and debug every app.

#### View Debugger

#### Time Profiler

The Time Profiler instrument gives insights into the system’s CPUs and how effective multiple cores and threads are used. Basically - how good your app is performing.

Always profile on a physical device, because your mac has a lot more horsepower

Use example:

- You made a super nice UICollectionView with pictures loaded from some API + a photo filter applied to each photo

- Everything looks great, but you notice the collectionView is not smooth as you want it to be 🧈

- You build the project for profiling (⌘+I), fire up the Time Profiler, press record and perform some scrolling in the collectionView

- After recording, you tick the "Separate by Thread" and "Hide System Libraries" settings in the call tree

  <img src="/Users/danylo/Downloads/11_littleArrow.png" alt="11_littleArrow" style="zoom:70%;" />

- You notice that the main thread is loaded up to 49% by your "withTonalFilter" function. That's the photo filter!

- You go into the function declaration and send this bad boi to a background thread, so that he no longer blocks the collectionView layout on the main thread

Call tree settings:

- **Separate by State**: groups results by your app’s lifecycle state. It is useful when you have some stuff going on in the background
- **Separate by Thread**: lets you understand which threads are responsible for the greatest amount of CPU use
- **Invert Call Tree**: makes the top-level methods visible without having to click through each call tree.
- **Hide System Libraries**: only shows symbols from your own app. It’s often useful to select this option since you can’t do much about how much CPU the system libraries are using.
- **Flatten Recursion**: shows recursive functions with one entry in each stack trace, rather than multiple times.
- **Top Functions**: makes Instruments consider the total time spent in a function as the sum of the time within that function, as well as the time spent in functions called by that function. So if function A calls B, then Instruments reports A’s time as the time spent in A plus the time spent in B

#### Allocations

#### Memory Debugger

#### Battery



### 4. Logging

### 5. Useful tools

---

Further Reading:

- https://www.apple.com/business/site/docs/iOS_Security_Guide.pdf
- https://github.com/OWASP/owasp-mstg#ios-testing-guide
