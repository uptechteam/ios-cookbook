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

## MVVM

Our needs satisfy fine-tuned for our purposes [Model-View-ViewModel](https://en.wikipedia.org/wiki/Model–view–viewmodel) architecture.
Entire application is divided into modules, each module represents a screen.
Typical module consists of following parts.

### View

`UIView` subclass and optional `.xib` interface builder file with layout (depends on screen complexity, but mostly on developer's preferance of view implementation). We recommend using interface builder wherever it is possible. 
All views are required to implement `render(props:)` method, which restores state of view from props object. More details about props below.
```swift
final class TeamChatView: UIView {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var titleLabel: UILabel!
    private let dataSource = TeamChatDataSource()
    private var props: TeamChatProps?

    override func awakeFromNib() {
        ...
    }

    func render(props: TeamChatProps) {
        if props.title != self.props?.title {
            titleLabel.text = props.title
        }    

        if props.messages != self.props?.messages {
            dataSource.render(messages: props.messages)
        }

        self.props = props
    }
}
```

### ViewController

`UIViewController` subclass, module's entrance point. ViewController doesn't contain any business logic, unlike with MVC. It strongly references to ViewModel and View objects. In most cases ViewController instantiates View and ViewModel by itself, but it can also support injecting them using initializer. A typical ViewController has a `bindViewModel()` method that binds View outputs to ViewModel inputs and ViewModel outputs to View inputs with reactive framework.

### Props

