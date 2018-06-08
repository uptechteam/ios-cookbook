# Architecture

By architecture here we mean a set of design patterns used across entire application. We believe that quality of code is much more important thing than specific architecture patterns.

However we have a number of reasons to use same architecture for every project we build.

## Why?

- Have a completed solution for new projects
- Decrease development time by reusing estabilished principles and techniques of solving similair (or not) problems
- Create consistent codebase to lower the barier to entry for switching developers between existing projects

## Requirements

- Testable, separated view and business logic
- Lightweight, small amount or no boilerplate code needed
- Easy to integrate to existing projects
- Multipurpose, suitable for all kinds of apps
- Designed for use with reactive framework (RxSwift)

## MVVM

Our needs satisfy fine-tuned [Model-View-ViewModel](https://en.wikipedia.org/wiki/Model–view–viewmodel) architecture.

Architecture is heavily dependent on [RxSwift](https://github.com/ReactiveX/RxSwift) framework, but may be easily used with any other reactive framework. 

Entire application is divided into modules, each module represents a screen.
Typical module consists of following parts.
- 📦 [Props](#props)
- 🎆 [View](#view)
- 🚦 [View Model](#viewmodel)
- 🚃 [View Controller](#viewcontroller)
- 🛠 [Services](#services)

### Props <a id="props"></a>

Immutable struct that contains all content needed for module to be displayed.

It is important to transmit entire view state using this object. This way view cannot enter invalid state because of incorrect configuration order.

Props must operate only with plain models created specifically for describing state of view. This means you cannot pass domain models (e.g. `Message` model initialized from JSON response) to view. You must create separated model inside module's props naming scope or outside (e.g. `MessageProps`) if you reuse view between different screens. This quality enables implementing view (and reducing QA cycle time) separately from business logic.

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

### View <a id="view"></a>

`UIView` subclass and `.xib` interface builder file with layout. 

From responsibilities division point of view view controller is same part of view layer as view itself, so this module's part is completely optional. Everything from it can be easily moved to view controller and functionality will remain same. However, we recommend implementing view separately from view controller to avoid growth of view controller's codebase.

All views are required to implement `render(props:)` method, which restores state of view from props object.
This method must always bring view to same state for same props (view state must not depend on previous calls).
If you implement animations, your view can rely on it's previous state to make a proper transition. For example, UITableView's data source may require previous rendered sections array to differentiate between it and current sections and do animated batch updates.

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

### View Model <a id="viewmodel"></a>

This object performs all business logic of module through transforming reactive inputs into outputs.

Inputs are sequences of events from view layer, that trigger network, services etc. Example sequences: `viewWillAppear`, `buyButtonTap`, `messageSelect`.
Outputs are sequences of events for view layer. Outputs contain cold observable sequence of props and hot observable sequences of triggers. This triggers include alerts, navigation to other screens etc.

To reuse functionality between different view models, we move use cases to service objects.

When screen functionality grows view model becomes complex and hard to maintain. To scale it linearly we implement Redux-like state inside view model. More info about it (here)[].

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
            // Function here shows how module's state transforms to view content.
            .map { messages, isLoadingMessages -> TeamChatProps in
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

### View Controller <a id="viewcontroller"></a>

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

In cases where module requires some local dependencies (e.g. profile details screen require profile id to fetch info), view controller has custom initializer that passes it's arguments to view model.
```swift
// ProfileDetailsViewController.swift
...

init(profileId: String) {
    viewModel = ProfileDetailsViewModel(profileId: profileId)
    super.init(nibName: nil, bundle: nil)
}
```

### Services <a id="services"></a>

Services are objects, that share logic between view models. 

If any functionality duplicates in different modules, you should move it into service. Example: `UserService` shares a logic of fetching and caching `User` model.

```swift
final class UserService: UserServiceProtocol {
    private let networkProvider: NetworkProviderProtocol
    private let storage: StorageProtocol

    init(
        networkProvider: NetworkProviderProtocol = Dependencies.shared.networkProvider,
        storage: StorageProtocol = UserDefaults.standard
    ) {
        self.networkProvider = networkProvider
        self.storage = storage
    }

    func fetchUser() -> Observable<User> {
        let key = "com.example.user"
        
        let fromCache = Observable.deferred { () -> Observable<User> in
            guard
                let data = self.storage[key] as Data?,
                let userFromCache = try? JSONDecoder().decode(User.self, from: data)
            else {
                return .empty()
            }

            return .just(userFromCache)
        }

        let fromNetwork = networkProvider.request(UserTarget())
            .do(onNext: { user in
                self.storage[key] = try? JSONEncoder().encode(user)
            })

        return fromCache.concat(fromNetwork)
    }
}
```

In most cases services are sets of independent methods, but they can also have their own state.
Example: `MessagesService` manages a queue of pending messages and sends them one by one in background. 

```swift
final class MessagesService: MessagesServiceProtocol {
    private let networkProvider: NetworkProviderProtocol

    private let sendMessageSubject = PublishSubject<LocalMessage>()

    init(networkProvider: NetworkProviderProtocol = Dependencies.shared.networkProvider) {
        self.networkProvider = networkProvider
    }

    func setupSending() -> Observable<Void> {
        enum Action {
            case addMessageToQueue(LocalMessage)
            case markAsSent(LocalMessage)
            case markAsFailed(LocalMessage, Error)
        }

        enum SendingStatus: Equatable {
            case pending
            case sent
            case failed(Error)
        }

        typealias State = [LocalMessage: SendingStatus]
        let initialState = State()

        func reduce(state: State, action: Action) -> State {
            var state = state

            switch action {
            case let .addMessageToQueue(message):
                state[message] = .pending

            case let .markAsSent(message):
                state[message] = .sent

            case let .markAsFailed(message, error):
                state[message] = .failed(error)
            }

            return state
        }

        let dispatchAction = PublishSubject<Action>()
        let sendMessageAction = sendMessageSubject.map(Action.addMessageToQueue)

        let state = Observable.merge([dispatchAction, sendMessageAction])
            .scan(initialState, accumulator: reduce)
            .startWith(initialState)
            .share(replay: 1, scope: .forever)

        return state
            .map { state -> LocalMessage? in
                return state
                    .filter { $0.value == .pending }
                    .map { $0.key }
                    .sorted()
                    .first
            }
            .flatMapLatest { message -> Observable<Action> in
                guard let message = message else {
                    return .empty()
                }

                return self.networkProvider.request(SendMessageTarget(message: message))
                    .map(Action.markAsSent)
                    .catchError { error in .just(Action.markAsFailed(error)) }
            }
            .do(onNext: dispatchAction.onNext)
            .map { _ in () }
            .ignoreElements()
    }

    func send(message: LocalMessage) -> Observable<Void> {
        return Observable.just(message)
            .do(onNext: sendMessageSubject.onNext)
            .map { _ in () }
    }
}
```

You might want to setup sending messages in object that will live for entire app lifecycle, e.g. `AppDelegate`.

```swift
// AppDelegate.swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    ...
    private let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        ...
        setupSendingMessages()

        return true
    }

    ...
    func setupSendingMessages() {
        Dependencies.shared.messagesService.setupSending()
            .subscribe()
            .disposed(by: disposeBag)
    }
}
```

And call send message method from any view model to add message to the pending queue.

