# Redux View Model

Our implementation of view model is heavily inspired by Redux. [Redux](https://redux.js.org) is a javascript framework for predictable state container. It helps to scale complexity with clear definition of state. 

We implement unidirectional data flow using reactive frameworks inside view model by hands.

View model constists of following parts:
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
