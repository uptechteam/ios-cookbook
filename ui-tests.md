# UI Tests 📱

This chapter of the cookbook can be considered as `exploration stage` for the following reasons:

- First is that the author does not have a lot of experience with UI tests, 
- Second, this chapter only talks about the UI test tools that comes bundled with Xcode, and not some of the other options like [iOS Snapshot Test Case](https://github.com/uber/ios-snapshot-test-case), [EarlGrey](https://github.com/google/EarlGrey) and [KIF](https://github.com/kif-framework/KIF),
- And the last is that the chapter ends with an opinionated paragraph, and might not show the opinion of the whole team.

### Introduction

Xcode 7 introduced UI testing, which lets us to create a UI test by recording interactions with the UI. UI testing works by finding an app’s UI objects with queries, synthesizing events, then sending them to those objects. The API enables us to examine a UI object’s properties and state in order to compare them against the expected state.

UI tests tools that we get with Xcode rests upon two core technologies: the XCTest framework and Accessibility.

- __XCTest__ provides the framework for UI testings, expanding on the same tools you already know from your Unit tests, like XCTAssert and all its relatives!

- __Accessibility__. Yes, you might be asking yourself "why this guy started talking about Accessibility" right now, but it is not only related, but crucial to have UI tests! We use Accessibility tools that are normally are used for providing disabled users a good experience on iOS to also detect what is exposed for external use (the views that on the screen, interactable or not) and use that information for testing.

Main reason we need to use Accessibility to extract information about the UI state of the app is that UI testing is a [black-box testing](https://en.wikipedia.org/wiki/Black-box_testing) framework. We shouldn't have to know anything about the implementation of the code we are testing. We can think of UI testing from the perspective of the user. The user doesn't care how our `MassiveViewController` works (or even that it exists 😈), so why should the UI Tests?

### Getting Started

If your project doesn't already have a target for UI tests, you can add one by going to `File > New > Target..` in Xcode and select a “UI testing bundle”. Then edit your app’s scheme to run your UI tests when testing, by going to `Product > Scheme > Edit Scheme..` in Xcode and adding your UI testing bundle under “Test”.

Before we start with and example, let's talk about using Accessibility to identify views in UI tests. To give our UI elements accesibility identifiers, we can either use interface builder or do it in the implementation code.
  - To use interface builder to give an identifier we need to select the view, go to `Identity inspector` tab and set a value for `Identifier` field located in the `Accessibility` section.
  - To give the identifier in code, set `accessibilityIdentifier` of the view to the identifier string you want like following: `anyView.accessibilityIdentifier = "someIdentifierString"`



Now let's start with the example:

```

import XCTest

class SignupUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        // We set this property to false to end test execution as soon as a failure occurs, main reason is UI tests are slower than the unit tests and we don't want to wait to find out we have a problem.
        continueAfterFailure = false
        
        app = XCUIApplication()
        
        // Here we pass launch arguments to `didFinishLaunchingWithOptions` in our AppDelegate. This is the only place where we can communicate with the app in UI tests since it is black-boxed, so we need to do the setup here.
        app.launchArguments.append(contentsOf: ["CLEAN_STORAGE", "ALPHA_ENV", "STUB_REQUESTS"])
    }

    func testSignup() {
        app.launch()
      
        let landing = app.otherElements["Landing View"]
        let signup = app.otherElements["Signup Card View"]
        let signupLoadingView = app.otherElements["SignupLoadingView"]

        // Test Closing with Close Button
        app.openSignupScreen()

        XCTAssert(signup.waitForExistence(timeout: 5))

        let closeButton = app.buttons["Signup Card Close Button"]
        closeButton.tap()

        XCTAssert(landing.waitForExistence(timeout: 5))

        // Test Closing with Swipe
        app.openSignupScreen()

        signup.swipeDown()

        XCTAssert(landing.waitForExistence(timeout: 5))

        // Test signing up
        app.openSignupScreen()

        XCTAssert(signup.waitForExistence(timeout: 5))

        let emailField = app.otherElements["SignupEmailFieldContainer"].otherElements.firstMatch
        let passwordField = app.otherElements["SignupPasswordFieldContainer"].otherElements.firstMatch

        emailField.clearAndEnterText(text: "new.account@aspiration.com")
        passwordField.clearAndEnterText(text: "password123")

        app.buttons["SignupButton"].tap()

        XCTAssert(signupLoadingView.waitForExistence(timeout: 5))

    }
}
```
