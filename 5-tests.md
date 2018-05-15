# Tests

We test our code. 

Although we don't aim for 100% code coverage, we keep it at a reasonable level. Ultimately, you decide by yourself what part of a specific project it is crucial to cover with tests and what kind of tests you need.

## Unit Tests

Pay most attention to covering your View Models' and singletons' code with unit tests.

It's easier to test the code that doesn't keep state, but instead only defines the logic of transforming inputs into outputs. Distribute responsibilities by injecting dependencies when possible. Keeping this in mind while designing your app will make it easier to write tests.

To write useful and conscious tests, think of what edge cases you can cover with them. If you mock so much of your logic that it makes testing conditions too unrealistic, maybe it's better to reconsider app design than keep writing mocks.

### RX Testing

We use RxTest framework for testing reactive code.

Use TestScheduler to simulate the events at certain moments of time:
```
let testScheduler = TestScheduler(initialClock: 0)

testScheduler.createColdObservable([next(201, ())])
    .asObservable()
    .bind(to: viewModel.testableObserver)
    .disposed(by: disposeBag)

let events = testScheduler.start { viewModel.testableObservable }.events
```

## UI Tests

UI tests help a lot with testing View Controllers and coordination, but take much more time to write and run than unit tests. Consider writing UI tests for long-term projects, projects with complicated UI design and navigation.

Testing the apps on a real network is a bit of a headache. It takes more time and you have to recreate test accounts after each database drop. Stub networking for UI tests.

## Behavior tests?

