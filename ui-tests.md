# UI Tests 📱

Xcode 7 introduced UI testing, which lets you create a UI test by recording interactions with the UI. UI testing works by finding an app’s UI objects with queries, synthesizing events, then sending them to those objects. The API enables you to examine a UI object’s properties and state in order to compare them against the expected state.[1]

Okay, sure. So, UI tests tools that we get with Xcode rests upon two core technologies: the XCTest framework and Accessibility.

- __XCTest__ provides the framework for UI testings, expanding on the same tools you already know from your Unit tests, like XCTAssert and all its relatives!

- __Accessibility__. Yes, you might be asking yourself "why this guy started talking about Accessibility" right now, but it is not only related, but crucial to have UI tests! We use Accessibility tools that are normally are used for providing disabled users a good experience on iOS to also detect what is exposed for external use (the views that on the screen, interactable or not) and use that information for testing.

Main reason we need to use Accessibility to extract information about the UI state of the app is that UI testing is a [black-box testing](https://en.wikipedia.org/wiki/Black-box_testing) framework. We shouldn't have to know anything about the implementation of the code we are testing. We can think of UI testing from the perspective of the user. The user doesn't care how our `MassiveViewController` works (or even that it exists 😈), so why should the UI Tests?

