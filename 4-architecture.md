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

### Props

Immutable struct that contains all content needed for screen to be displayed.
It is important to transmit entire view state using this object. This way view cannot enter invalid state because of incorrect configuration order.
Props object should conform to `Equatable`, so it is required to contain only equatable value type properties.

```swift
struct TeamChatProps: Equatable {
    struct Message: Equatable {
        let body: String
        let senderName: String
        let senderAvatarUrl: URL
        let createdAt: Date
    }

    let messages: [Message]
    let title: String
}
```

### View

`UIView` subclass and optional `.xib` interface builder file with layout. 

All views are required to implement `render(props:)` method, which restores state of view from props object.

```swift
final class TeamChatView: UIView, NibInstantiatable {
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

### View Model

Plain old Swift object, performs all business logic of module.

```swift
final class TeamChatViewModel {
    struct Inputs {
        let viewWillAppear: Observable<Void>
    }

    struct Outputs {
        let props: Observable<TeamChatProps>
        let alert: Observable<String>
    }

    private let networkProvider: NetworkProviderProtocol

    init(networkProvider: NetworkProviderProtocol = Dependencies.shared.networkProvider) {
        self.networkProvider = networkProvider
    }

    func makeOutputs(from inputs: Inputs) {
        let alertSubject = PublishSubject<String>()
        let isLoadingMessages = BehaviorSubject<Bool>(value: false)

        let messages = inputs.viewWillAppear
            .flatMapLatest { () -> Observable<[Messages]> in
                isLoadingMessages.onNext(true)
                return self.networkProvider.request(TeamMessagesTarget())
                    .catchError { error in
                        alertSubject.onNext(error.localizedDescription)
                        return .empty()
                    }
                    .do(onCompleted: { isLoadingMessages.onNext(false) })
            }
            .startWith([])
            .share(replay: 1, scope: .forever)

        let props = Observable.combineLatest(messages, isLoadingMessages) { ($0, $1) }
            .map { messages, isLoadingMessages -> TeamChatProps in
                // It is important to use separated models for domain and props messages to decouple view from business logic
                let propsMessages = messages
                    .map { message -> TeamChatProps.Message in
                        return TeamChatProps.Message(
                            body: message.body,
                            senderName: message.sender.name,
                            senderAvatarUrl: message.sender.avatarUrl,
                            createdAt: message.createdAt
                        )
                    }

                let title = isLoadingMessages ? "Loading" : "Team Chat"

                return TeamChatProps(
                    messages: propsMessages,
                    title: title
                )
            }

        self.props = props
        self.alert = alertSubject
    }
}
```

### View Controller

`UIViewController` subclass, module's entrance point. 

View controller doesn't contain any business logic, unlike with MVC. It strongly references to view model and view objects. In most cases view controller instantiates view and view model by itself, but it can also support injecting them using initializer. 

A typical view controller has a `bindViewModel()` method that binds view outputs to view model inputs and view model outputs to view inputs with reactive framework.

```swift
final class TeamChatViewController: UIViewController {
    private lazy var teamChatView = TeamChatView.instantiateFromNib()
    private lazy var viewModel = TeamChatViewModel()
    private let disposeBag = DisposeBag()

    override func loadView() {
        self.view = teamChatView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }

    private func bindViewModel() {
        let inputs = TeamChatViewModel.Inputs(
            viewWillAppear: self.rx.viewWillAppear
        )

        let outputs = viewModel.makeOutputs(from: inputs)

        outputs.props
            .observeOn(MainScheduler.instance)
            .bind { [weak self] in self?.render(props: $0) }
            .disposed(by: disposeBag)

        outputs.alert
            .observeOn(MainScheduler.instance)
            .bind { [weak self] in self?.showAlertController(message: $0) }
            .disposed(by: disposeBag)
    }

    private func render(props: TeamChatProps) {
        teamChatView.render(props: props)
    }
}
```
