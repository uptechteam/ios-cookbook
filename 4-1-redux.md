# Redux View Model

### Motivation

As applications complexity grows, our code must manage more state than ever before. And we know that [shared mutable state is bad](https://softwareengineering.stackexchange.com/a/148109).

That's where [Redux](https://redux.js.org) comes in and attempts to **make state mutations predictable**.

### Three Redux Principles

#### 1. Single source of truth

The state of your whole application is stored in an object tree within a single store.

#### 2. State is read-only

The only way to change the state is to emit an action, an object describing what happened.

#### 3. Changes are made with pure functions

To specify how the state tree is transformed by actions, you write pure reducers.

Please refer to the [official Redux ReadMe](https://redux.js.org) for more. It has tons of useful information.

--

We are not trying to port Redux on iOS, instead we applied core principles to our View Models. It helps us to scale complexity linearly and build even the most complicated screens with ease. 

Redux View Model constists of the following parts:

- State
- Actions
- Layout
- Reducer
- View Model

## State

State is a plain struct that holds result of view model work. State contains all info that anyhow affects view model behavior or view.
It doesn't meant to be exposed from view model to other architecture components anyhow and must be used by view model's parts only.

```swift
struct TeamChatState {
  var messages: [Message]
  var isLoadingMessages: Bool
}
```

## Actions

Actions are data structures that represent a state modification. Usually actions replicate state properties, where each action update one property at time. There might be exceptions when action might represent more meaningful work, e.g. `clearInputData` action that is used for restoring initial state of inputted data.

```swift
enum TeamChatAction {
  case loadMessages([Message])
  case toggleLoadingMessages(Bool)
}
```

## Reducer

Reducer is a function that applies actions to state. For convinience we implement it as a single method of Reducer class. 
It is important to implement it without side effects to be sure that only way of modifying state is dispatching actions.

```swift
final class TeamChatReducer: TeamChatReducerProtocol {
  func reduce(state: TeamChatState, action: TeamChatAction) -> TeamChatState {
    var state = state

    switch action {
    case let .loadMessages(messages):
      state.messages = messages

    case let .toggleLoadingMessages(on):
      state.isLoadingMessages = on
    }

    return state
  }
}
```

## Layout

Layout is function that creates props from state. Function must be free to make sure props (visual representation) depends only on current state.

```swift
final class TeamChatLayout: TeamChatLayoutProtocol {
  func makeProps(from state: TeamChatState) -> TeamChatProps {
    let messages: [TeamChatProps.Message] = state.messages
      .map { message -> TeamChatProps.Message in
        return TeamChatProps.Message(
          body: message.body,
          senderName: message.sender.name,
          senderAvatarUrl: message.sender.avatarUrl,
          createdAt: message.createdAt
        )
      }

    let title: String = state.isLoadingMessages ? "Loading" : "Chat"

    return TeamChatProps(
      messages: messages,
      title: title
    )
  }
}
```

## View Model

View model is a part that combines and wraps all other parts using reactive framework.

```swift
final class TeamChatViewModel {
  struct Inputs {
    let viewWillAppear: Observable<Void>
    let sendMessage: Observable<String>
  }

  struct Outputs {
    let props: Observable<TeamChatProps>
    let alert: Observable<String>
  }

  private let actionCreators: TeamChatActionCreatorsProtocol
  private let reducer: TeamChatReducerProtocol
  private let layout: TeamChatLayoutProtocol
  private let scheduler: SchedulerType

  init(
    actionCreators: TeamChatActionCreatorsProtocol = TeamChatActionCreators(),
    reducer: TeamChatReducerProtocol = TeamChatReducer(),
    layout: TeamChatLayoutProtocol = TeamChatLayout(),
    scheduler: SchedulerType = MainScheduler.instance
    ) { 
    self.actionCreators = actionCreators
    self.reducer = reducer
    self.layout = layout
    self.scheduler = scheduler
  }

  func makeOutputs(from inputs: Inputs) -> Outputs {
    let (messagesAction, messagesAlert) = actionCreators.messages(viewWillAppear: inputs.viewWillAppear)
    let (sendMessageAction, sendMessageAlert) = actionCreators.sendMessage(sendMessage: inputs.sendMessage)

    let actions = Observable.merge([
      messagesAction,
      sendMessageAction
    ])

    let initialState = TeamChatState(
      messages: [],
      isLoadingMessages: false
    )

    actions
      .observeOn(scheduler)
      .scan(initialState, accumulator: reducer.reduce)
      .startWith(initialState)
      .share(replay: 1, scope: .forever)

    let props = state
      .map(layout.makeProps)
      .share(replay: 1, scope: .forever)

    return Outputs(
      props: props,
      alert: Observable.merge([messagesAlert, sendMessageAlert])
    )
  }
}
```

Table of content
- About Redux
- Our implementation

Parts
- State
- Action
- Reducer
- Action Creators
- Layout
- Relation to architecture
