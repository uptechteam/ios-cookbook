import RxSwift

final class ReduxStore<State, Action> {

  typealias Reducer = (State, Action) -> State
  typealias Dispatch = (Action) -> Void
  typealias StateProvider = () -> State
  typealias Middleware = (@escaping Dispatch, @escaping () -> State) -> (@escaping Dispatch) -> Dispatch

  private let reducer: Reducer

  let state: Observable<State>
  private let stateVariable: Variable<State>
  private var dispatchFunction: Dispatch!

  init(
    initialState: State,
    reducer: @escaping Reducer,
    middlewares: [Middleware]
    ) {
    let stateVariable = Variable(initialState)

    self.reducer = reducer
    self.state = stateVariable.asObservable()

    let defaultDispatch: Dispatch = { action in
      stateVariable.value = reducer(stateVariable.value, action)
    }

    self.stateVariable = stateVariable
    self.dispatchFunction = middlewares
      .reversed()
      .reduce(defaultDispatch) { (dispatchFunction, middleware) -> Dispatch in
        let dispatch: Dispatch = { [weak self] in self?.dispatch(action: $0) }
        let getState: StateProvider = { stateVariable.value }
        return middleware(dispatch, getState)(dispatchFunction)
    }
  }

  func dispatch(action: Action) {
    dispatchFunction?(action)
  }

  func getState() -> State {
    return stateVariable.value
  }
}
