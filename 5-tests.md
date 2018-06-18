# Tests

### General Rules

##### 1. We test our code.

Although we don't aim for 100% code coverage, we keep it at a reasonable level. Ultimately, you decide by yourself what part of a specific project it is crucial to cover with tests and what kind of tests you need.

##### 2. Naming

Test classes should be named as `\(TestingClassName)Tests.swift`.

Test function names should reflect the behaviour which is being tested: `func test_theTestedBehaviourAndContext_expectedResult()`, or more concise for simple cases: `func test_theTestedBehaviour()`. For example:

```swift
class ProfileServiceTests: XCTestCase {
	func test_gettingProfileWithoutLogin_emitsError() { ... }
	func test_gettingProfileWithoutId_returnsMyProfile() { ... }
}
```

###### Why do we do this?

For the best possible naming, imagine the situation when you (or one of your colleagues) have to deal with failed tests in your project. Small, explicitly named functions like
```swift
func test_factorialForZero_returns1()
```
will inform you exactly on what went wrong, but with functions like
```swift
func test_checkMyMathIsOK()
```
You'll probably have to dive deeper into the code.

##### 3. Location

Test files should be placed in the same location as a tested class, so the project structure looks like that:

```
|-- ViewModels
  |-- LoginViewModel.swift
  |-- LoginViewModelTests.swift
```

## Unit Tests
Pay most attention to covering your View Models and Domain Layer Services code with unit tests.

It's easier to test the code that doesn't keep state, but instead only defines the logic of transforming inputs into outputs. Distribute responsibilities by injecting dependencies when possible. Keeping this in mind while designing your app will make it easier to write tests.

To write useful and conscious tests, think of what edge cases you can cover with them. If you mock so much of your logic that it makes testing conditions too unrealistic, maybe it's better to reconsider app design than keep writing mocks.

### Rx Testing

We use RxTest framework for testing reactive code.

##### Usage

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

#### 1. To test `Void` type, compare two `debugDescription`

*(WARNING: it may work wrong for types with implementation of `CustomDebugStringConvertible`)*

```swift
XCTAsserEqual(events.debugDescription, expectedEvents.debugDescription)
```

###### Why do we do this?
Void is not equatable, and we can't compare it. In debug description we will get some information about events (example: `next(()) @ 200`) where `next(())` our void event and `@ 200` it's time  in milliseconds when it comes.

#### 2. If you use the specific scheduler, you should inject it in ViewModel

```swift
class ViewModel {
  let userName: Observable<String>
  let lastUpdatedUserName: Observable<Date>

  init(
    userService: UserServiceProtocol,
    scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background)
  ) {
      let userName = userService.currentUser
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
let viewModel = ViewModel(userService: testUserService, scheduler: testScheduler)
```

###### Why do we do this?

When we test our events we use `TestScheduler` which conforms to the `SchedulerType`. The problem here is, when you would like to move your sequence to other thread you will lose events.
Example: 

```
(1) we don't inject a scheduler
TestScheduler -----x-x-         -----> Here we try catch it
                        \    
    observerOn(Scheduler) -x-x-------> Here nothing


(2) we do inject a scheduler
TestScheduler -----x-x-         -x-x-> Here we try catch it
                        \     /
observerOn(TestScheduler) -x-
```

#### 3. Also, if we want to test `Date` type, we should inject a closure which will return the date

```swift
typealias CurrentDateFactory = () -> Date
class ViewModel {
  let userName: Observable<String>
  let lastUpdatedUserName: Observable<Date>

  init(
    userService: UserServiceProtocol,
    scheduler: SchedulerType = ConcurrentDispatchQueueScheduler.init(qos: .background),
    currentDateFactory: @escaping CurrentDateFactory = { Date() }
  ) {
  let userName = userService.currentUser
    .observeOn(scheduler)
    .map { $0.name }
    .share(replay: 1, scope: .whileConnected)

    let lastUpdatedUserName = userName.map { _ in currentDateFactory() }
    self.userName = userName
    self.lastUpdatedUserName = lastUpdatedUserName
    }

}

// Usage in tests:
let testScheduler = TestScheduler(initialClock: 0)
let testDate = Date()
let currentDateFactory = { return testDate }
let viewModel = ViewModel(userService: testUserService, scheduler: testScheduler, currentDateFactory: currentDateFactory)
```

###### Why do we do this?
The `Date()` initializer creates a current date using real system time. If a View Model calls it directly, there's no way to check its correctness in unit tests, because we don't know (with the required accuracy) what date it should contain. So, if in the suggested example the View Model created the date itself, it would be different from the `testDate`, because we created `testDate` earlier than the View Model.

### Mocking
The best way to test some `ViewModel` which contains a `Service` (Domain Layer Services) is to create some mock of this `Service`. For this, we need to use `protocol` and create some class which will conform to it.
Example: 

```swift
// Protocol of our service 
protocol UserServiceProtocol {
  var currentUser: Observable<User>
  func fetchUser() -> Observable<Void>
}

// Mocking the class which conforms to our protocol
class TestUserService: UserServiceProtocol {

  func fetchUser() -> Observable<Void> {
    return testFetchUser
  }

  var currentUser: Observable<User> {
    return testCurrentUser
  }

  private let testCurrentUser: Observable<User>
  private let testFetchUser: Observable<Void>
  init(
    testCurrentUser: Observable<User> = .empty(),
    testFetchUser: Observable<Void> = .empty()
  ) {
    self.testCurrentUser = testCurrentUser
    self.testFetchUser = testFetchUser
  }
}
let testScheduler = TestScheduler(initialClock: 0)
let date = Date()
let currentDateFactory = { return date }
let testUser = User(id: 1)

// I recommend you mock only `func` or `properties` which you will use in viewModel. 
// We set a default value for testFetchUser to Observable.empty().
// It will make our life easier :D

let testCurrentUser = Observable<User>.deferred {
  return self.testScheduler.createColdObservable([next(0, testUser)]).asObservable()
}

let testUserService: UserServiceProtocol = TestUserService(testCurrentUser: testCurrentUser)

let viewModel = ViewModel(userService: testUserService, scheduler: testScheduler, currentDateFactory: currentDateFactory)

```

As a conclusion, I would like to give a real [example](In%20the%20result%20i%20would%20like%20to%20give%20a%20real%20example.%20https://gist.github.com/romanfurman6/f3846351b669eacee3f786611edff72d).


## UI Tests

UI tests help a lot with testing View Controllers and coordination, but take much more time to write and run than unit tests. Consider writing UI tests for long-term projects, projects with complicated UI design and navigation.

Testing the apps on a real network is a bit of a headache. It takes more time and you have to recreate test accounts after each database drop. Stub networking for UI tests.
