# Tests

### General Rules
We test our code.

Although we don't aim for 100% code coverage, we keep it at a reasonable level. Ultimately, you decide by yourself what part of a specific project it is crucial to cover with tests and what kind of tests you need.

Test class should be named like `\(TestingClassName)Tests.swift`, put every test file in the same directory that contains the main class.
```
|-- ViewModels
  |-- LoginViewModel.swift
  |-- LoginViewModelTests.swift
```


Name of tests should be like `func test_WhatWeTesting()`, for example:

```swift
func test_isLoadingState()
func test_AuthenticationErrorHandling()
```

## Unit Tests
Pay most attention to covering your View Models' and singletons'(Doman Layer Services) code with unit tests.

It's easier to test the code that doesn't keep state, but instead only defines the logic of transforming inputs into outputs. Distribute responsibilities by injecting dependencies when possible. Keeping this in mind while designing your app will make it easier to write tests.

To write useful and conscious tests, think of what edge cases you can cover with them. If you mock so much of your logic that it makes testing conditions too unrealistic, maybe it's better to reconsider app design than keep writing mocks.

### Rx Testing

We use RxTest framework for testing reactive code.

### Using

Use `TestScheduler` to simulate the events at certain moments of time:
```swift
let testScheduler = TestScheduler(initialClock: 0)
testScheduler.createColdObservable([next(201, "String")])
  .asObservable()
  .bind(to: viewModel.testableObserver)
  .disposed(by: disposeBag)

let expectedEvents = [next(201, "String")]
let events = testScheduler.start { viewModel.testableObservable }.events
XCTAsserEqual(events, expectedEvents)
```

### Best practices

##### 1) To test `Void` type, compare two `debugDescription`:

```swift
XCTAsserEqual(events.debugDescription, expectedEvents.debugDescription)
```

##### 2) If you use the specific scheduler, you should inject it in ViewModel:

```swift
class ViewModel {
  let userName: Observable<String>
  let lastUpdatedUserName: Observable<Date>

  init(
    authService: AuthServiceProtocol,
    scheduler: SchedulerType = ConcurrentDispatchQueueScheduler.init(qos: .background)
  ) {
      let userName = authService.currentUser
        .observeOn(scheduler)
        .map { $0.name }
        .share(replay: 1, scope: .whileConnected)

      let lastUpdatedUserName = userName.map { _ in Date() }
      self.userName = userName
      self.lastUpdatedUserName = lastUpdatedUserName
  }
}

// Usage in tests:

let testScheduler = TestScheduler(initialClock: 0)
let viewModel = ViewModel(authService: testAuthService, scheduler: testScheduler)
```

##### 3) Also, if we want to test `Date` type, we should inject a closure which will return the date:

```swift
typealias DateProducer = () -> Date
class ViewModel {
  let userName: Observable<String>
  let lastUpdatedUserName: Observable<Date>

  init(
    authService: AuthServiceProtocol,
    scheduler: SchedulerType = ConcurrentDispatchQueueScheduler.init(qos: .background),
    dateProducer: @escaping DateProducer = { Date() }
  ) {
  let userName = authService.currentUser
    .observeOn(scheduler)
    .map { $0.name }
    .share(replay: 1, scope: .whileConnected)

    let lastUpdatedUserName = userName.map { _ in dateProducer() }
    self.userName = userName
    self.lastUpdatedUserName = lastUpdatedUserName
    }

}

// Usage in tests:
let testScheduler = TestScheduler(initialClock: 0)
let date = Date()
let dateProducer = { return date }
let viewModel = ViewModel(authService: testAuthService, scheduler: testScheduler, dateProducer: dateProducer)
```

## UI Tests

UI tests help a lot with testing View Controllers and coordination, but take much more time to write and run than unit tests. Consider writing UI tests for long-term projects, projects with complicated UI design and navigation.

Testing the apps on a real network is a bit of a headache. It takes more time and you have to recreate test accounts after each database drop. Stub networking for UI tests.
