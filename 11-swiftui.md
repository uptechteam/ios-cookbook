# Cookbook SwiftUI

Welcome to the SwiftUI Cookbook! In this cookbook, we will explore various techniques and best practices for building beautiful and functional user interfaces with SwiftUI.

## Table of Contents

- [Keep your code clean and organized](#keep-your-code-clean-and-organized)
- [Configuring SwiftUI views](#configuring-swiftui-views)
- [Use ViewModifiers to reuse styling logic](#use-viewmodifiers-to-reuse-styling-logic)
- [Use structs for data modeling](#use-structs-for-data-modeling)
- [Use environment objects for shared state](#use-environment-objects-for-shared-state)
- [Accessibility](#accessibility)
---

### Keep your code clean and organized
Use white space and indentation to make your code easy to read. Also, separate your code into logical blocks using extensions or subviews. Add each modifier on newline.
```swift
struct ContentView: View {
    var body: some View {
        VStack { 
            Text("Hello, world!")
                .padding()
                
            Button(action: {
                print("Button tapped") 
             }) { 
                Text("Tap me!") 
             } 
        } 
    } 
}
```
When creating a view with a lot of instances inside, it's important to keep performance in mind. Creating too many instances or having too complex of a view hierarchy can lead to slow performance, especially on older devices.

To improve performance, you can follow these best practices:

1. Use reusable views: If you have a lot of instances of the same view, consider creating a reusable view instead of creating a new instance for each item. For example, if you have a list of items, create a single item view and reuse it for each item.
2.  Use lazy loading (`LazyVStack/LazyHStack` and `LazyHGrid/LazyVGrid`): If you have a lot of data to display, consider using lazy loading to only load and display the data that is currently visible on the screen. This can significantly improve performance, especially for large data sets.
3.  Avoid complex view hierarchies: Try to keep your view hierarchy as simple as possible. If you have a complex view hierarchy, consider breaking it down into smaller views or using a different layout. Avoid computed `View` property.
```swift
// Not Preferred
struct HomeView: View {
    var body: some View {
        content
    }

    var content: some View {
        VStack {
            Text("Content")
        }
    }
}

// Preferred
struct HomeView: View {
    var body: some View {
        HomeContentView(text: "Content")
    }
}

struct HomeContentView: View {
    var text: String

    var body: some View {
        VStack {
            Text(text)
        }
    }
}
```
---

### Configuring SwiftUI views
If a **View** contains more than three variables, it is advisable to employ an additional **struct** for initialization.
- Avoid long initialization block. 
```swift
struct HomeView: View {

    struct HomeViewConfig {
        var title: String
        var header: String
        var content: String
        var caption: String
    }

    var config: HomeViewConfig

    var body: some View {
        VStack {
            Text(config.title)
                .font(.title)
  
            Text(config.header)
                .font(.headline)

            Text(config.content)
                .font(.body)
        }
    }
}
```

- Use `enum` when `View` has multiple callbacks
```swift 
struct ContentView: View {

    enum ContentViewAction {
        case edit
        case itemId(Int)
    }

    var callback: (ContentViewAction) -> Void

    var body: some View {
        VStack {
            Button("Edit") {
                callback(.edit)
            }
             
            Button("Item 0") {
                callback(.itemId(0))
            }
        }
    }
}
```
---

### Use ViewModifiers to reuse styling logic
In SwiftUI, modifiers are used to style views. They allow you to change the appearance and behavior of a view without changing its underlying properties. Modifiers can be powerful, but they can also slow down your app if overused. Try to use modifiers only when necessary and avoid using them excessively.
```swift
struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .foregroundColor(.green)
            .font(.title)
            .background(Color.white)
            .watermarked(with: "UpTech") 
    } 
}

struct Watermark: ViewModifier {
    var text: String

    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
            Text(text)
                .font(.caption)
        }
    }
}

extension View {
    func watermarked(with text: String) -> some View {
        modifier(Watermark(text: text))
    }
}
```
---

### Use structs for data modeling
SwiftUI works best with structs. Use structs to model your data and pass it between views. This allows you to take advantage of SwiftUI's data binding and state management features.
```swift
struct Person: Identifiable {
    var id = UUID()
    var name: String
    var age: Int
} 

struct ContentView: View {
    var people = [ 
        Person(name: "John", age: 30),
        Person(name: "Jane", age: 25),
        Person(name: "Bob", age: 40) 
    ]
     
    var body: some View { 
        List(people) {
            person in Text(person.name) 
        }
    }
}
```
---

### Use environment objects for shared state
Environment objects are a way to share state between views in your app. Use environment objects to manage shared state, such as user preferences or app settings. Note: use `@EnvironmentObject` for app-wide purposes only and prefer `@ObservedObject` and `@StateObject` for VMs and view-specific logic items.
```swift
final class UserSettings: ObservableObject {
    @Published var darkMode = false
}

struct ContentView: View { 
    @EnvironmentObject var userSettings: UserSettings 
    
    var body: some View { 
        VStack { 
            Toggle(isOn: $userSettings.darkMode) {
                Text("Dark mode")
            } 
            Text("Hello, world!") 
                .padding() 
                .foregroundColor(userSettings.darkMode ? .white : .black)
                .background(userSettings.darkMode ? .black : .white) 
        } 
    }
}
```

### Accesability
Accessibility is an important aspect of building inclusive apps that can be used by everyone. In this section, we will explore how to make your SwiftUI app more accessible.

You can make your SwiftUI app more accessible by using several techniques, such as providing labels and hints for views, adjusting font sizes and colours, and enabling voiceover and other assistive technologies.
```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
                .font(.largeTitle)
                .foregroundColor(.blue)
                .padding()
                .accessibility(label: Text("Greeting"))
                .accessibility(hint: Text("Double tap to say hello")) 
        } 
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement()
        .accessibility(addTraits: .isHeader)
    }
}
```
