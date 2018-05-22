# Architecture

By architecture here we mean a set of design patterns used across entire application. We believe that quality of code is much more important thing than specific architecture patterns.

However we have a number of reasons to use same architecture for every project we build.

## Why?

- Have a completed solution for new projects, nobody wants to create a bicycle every single time
- Decrease development time by reusing estabilished principles and techniques of solving similair (or not) problems
- Create consistent codebase to lower the barier to entry for switching developers between existing projects

## Requirements

- Testable, separated view and business logic
- Lightweight, small amount or no boilerplate code needed
- Easy to integrate to existing projects
- Multipurpose, suitable for all kinds of apps
- Designed for use with reactive framework (RxSwift)

