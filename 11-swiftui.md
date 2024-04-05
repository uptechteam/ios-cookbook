# Cookbook SwiftUI

Welcome to the SwiftUI Cookbook! In this cookbook, we will explore various techniques and best practices for building beautiful and functional user interfaces with SwiftUI.

## Table of Contents

- [1. Keep your code clean and organized](#1.-keep-your-code-clean-and-organized)
- [2. Keep performance in mind](#2.-keep-performance-in-mind)
- [3. Configuring SwiftUI views](#3.-configuring-swiftui-views)
- [4. Use ViewModifiers to reuse styling logic](#4.-use-viewmodifiers-to-reuse-styling-logic)
- [5. Use structs for data modeling](#5.-use-structs-for-data-modeling)
- [6. Use environment objects for shared state](#6.-use-environment-objects-for-shared-state)
- [7. Enhancing Accessibility with SwiftLint Rules](#7.-enhancing-accessibility-with-swiftlint-rules)
---

### 1. Keep your code clean and organized
- **Whitespace and Indentation**: Use whitespace and proper indentation to make your code more readable. This helps in distinguishing between different blocks of code and makes it easier to navigate through your codebase.
- **Logical Code Separation**: Separate your code into logical blocks. This can be achieved by using extensions or by breaking down complex views into smaller subviews. This approach not only makes your code cleaner but also more modular and easier to maintain.
- **Modifiers on New Lines**: Place each modifier on a new line. This practice enhances readability, especially when you are using multiple modifiers on a single view. It makes it easier to track which modifiers are applied and in what order.

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

### 2. Keep performance in mind
When creating a view with a lot of instances inside, it's important to keep performance in mind. Creating too many instances or having too complex of a view hierarchy can lead to slow performance, especially on older devices.

To improve performance, you can follow these best practices:

1. **Use Reusable Views**: For repeated elements, create a reusable view instead of new instances for each item. This reduces memory usage and improves performance.
Example:

    ```swift
    struct ItemView: View {
	    let item: Item
	
	    var body: some View {
		    Text(item.name)
		    // Other view components 
	    }
    }

    struct ItemsListView: View {
	    let items: [Item]
	
        var body: some View {
		    List(items) { item in
			    ItemView(item: item)
		    }
	    }
    }
    ```
2.  **Use Lazy Loading**: For large datasets, use `LazyVStack`, `LazyHStack`, `LazyHGrid`, and `LazyVGrid`. These structures load views on demand, improving performance for large collections. But be aware that these structures load data once and do not reuse cells. If you will have a large number of cells you should use `List`.
3.  **Avoid Complex View Hierarchies**: To enhance rendering performance and maintain readability in SwiftUI, it's important to manage the complexity of view hierarchies effectively:
    - **Simplify View Hierarchies**: Aim to keep your view hierarchies as simple as possible. A complex hierarchy can slow down rendering and make your code harder to understand and maintain.
    - **Break Down When Necessary**: When your view hierarchy exceeds four levels of nesting, consider refactoring further nested views into separate, dedicated views. This "healthy nesting" rule helps in balancing the need for simplicity without fragmenting your codebase into too many small, unique components.
    - **Limit Computed `View` Properties**: Be cautious with the use of computed `View` properties. While they can be useful, excessive use may inadvertently increase complexity and impact performance. They are best used when they contribute to reducing overall view complexity or are essential for dynamic view updates.
    - **Strategic Refactoring**: Refactoring into smaller views is recommended, but only when it logically makes sense. This approach helps in avoiding an excessive number of small, unique views, which can be as detrimental as overly complex hierarchies.

    By following these guidelines, you can create a well-structured and performant SwiftUI application. The key is to strike a balance: simplify and refactor where necessary, but avoid unnecessary fragmentation of your views. 
    Example:

    ```swift
    // Complex hierarchy (Avoid)
    struct ComplexView: View {
        var body: some View {
            VStack {
                Text("Title")

                Text("Subtitles")

                Image("Logo")

                Text("Description")

	            Button("Login") {
		            // Action
	            }
            }
        }
    }

    // Simplified hierarchy (Preferred)
    struct SimpleView: View {
        var body: some View {
            VStack {
                HeaderView()
                // Other subviews
            }
        }
    }

    struct HeaderView: View {
        var body: some View {
            Text("Title")

            Text("Subtitles")
            // Other subviews
        }
    }
    ```
---

### 3. Configuring SwiftUI views
If a **View** contains more than three variables, it is advisable to employ an additional **struct** for initialization.
- Avoid long initialization block:

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

- Use `enum` when `View` has multiple callbacks:
    
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

### 4. Use ViewModifiers to reuse styling logic
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

### 5. Use structs for data modeling
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

### 6. Use environment objects for shared state
Environment objects in SwiftUI are powerful tools for sharing state across multiple views. However, their use should be carefully considered. Here are the guidelines:
- **App-Wide Shared State**: Use `@EnvironmentObject` for state that is truly global or app-wide, such as user preferences, themes, or authentication states. This should be used sparingly, as overuse can lead to tightly coupled components and makes tracking data flow more difficult.
- **View Models (VMs) and View-Specific Logic**: Prefer using `@ObservedObject` and `@StateObject` for state that is specific to a particular view or its closely related components. This approach promotes better encapsulation and makes your views more reusable and easier to test.
```swift
// Global state using @EnvironmentObject
final class UserSettings: ObservableObject {
	@Published var darkMode = false
}

struct AppView: View {
	var body: some View {
		ContentView()
			.environmentObject(UserSettings())
	}
}

// Local state using @StateObject or @ObservedObject
struct ContentView: View {
	@StateObject var viewModel = ContentViewModel()
	var body: some View {
		// View implementation
	}
}

final class ContentViewModel: ObservableObject {
	// View-specific state
}
```
---

### 7. Enhancing Accessibility with SwiftLint Rules
Accessibility is an important aspect of building inclusive apps that can be used by everyone. In this section, we will explore how to make your SwiftUI app more accessible.

In addition to the standard SwiftUI accessibility features, it's beneficial to enforce certain accessibility best practices using SwiftLint, a widely-used tool for maintaining Swift code quality. Specific `SwiftLint` rules that are particularly useful for accessibility are:
1. **`accessibility_label_for_text` Rule**: This rule ensures that all text elements have accessibility labels, especially when the text is not self-explanatory or when additional context is needed for screen readers.
2. **`accessibility_custom_action` Rule**: Use this rule to ensure that custom actions are provided for interactive elements that perform non-standard functions. This is crucial for users who rely on assistive technologies to understand what actions they can perform on a UI element.
3. **`accessibility_dynamic_type_text` Rule**: This rule checks that your app's text elements support dynamic type. This is important for users who need larger text sizes, ensuring that your app's UI adjusts text size based on the user's settings.
4. **`accessibility_highlighted_elements` Rule**: Ensure that elements which are highlighted or selected have appropriate accessibility traits, so that their state is clear to users with visual impairments.
5. **`accessibility_minimum_tappable_area` Rule**: Enforce a minimum tappable area for buttons and other interactive elements, ensuring they are easily accessible for users with motor impairments.

You can make your SwiftUI app more accessible by using several techniques, such as providing labels and hints for views, adjusting font sizes and colours, and enabling voiceover and other assistive technologies.
```swift
struct ContentView: View {
    var body: some View {
        VStack {
	        Text("Welcome")
		        .accessibilityLabel("Welcome greeting")
		        // Ensures that the text has an accessibility label

		    Button(action: customAction) {
			    Text("More Info")
			}
			.accessibilityAction(named: "Get More Information", customAction)
			// Adds a custom accessibility action

			Text("Adjustable Text")
				.font(.system(size: 16))
				.accessibilityDynamicTypeText()
			// Ensures support for dynamic type

			Button("Selected Item") {
				// Action
			}
			.accessibility(addTraits: [.isButton, .isSelected])
			// Marks the button as selected

			Button("Tap Me") {
				// Action
			}
			.frame(minWidth: 44, minHeight: 44)
			.accessibilityMinimumTappableArea()
			// Ensures a minimum tappable area
		}
    }
}
```