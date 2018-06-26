# Redux View Model

[Redux](https://redux.js.org) is a Javascript framework for predictable state containers. It helps to scale complexity with transparent and clear definition of state. Our implementation of view model is heavily inspired by it.

We implement unidirectional data flow using reactive frameworks inside view model by hands.
```swift
struct TeamChatState {
  var messages: [Message]
  var isLoadingMessages: Bool
}
```
```swift
enum TeamChatAction {
  case loadMessages([Message])
  case toggleLoadingMessages(Bool)
}
```
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
