```swift
All Objective-C Exceptions
    // Catches exceptions thrown by Objective-C code.
    // Default Xcode breakpoint created by clicking "+" to add breakpoint -> "Exception Breakpoint".
    // Change "Exception: All" to "Exception: Objective-C".
    
-[UIApplication main]
    // Helps when printing objects via the debugger by making it aware of the classes in UIKit.
    // Symbolic breakpoint created by clicking "+" to add breakpoint -> "Symbolic Breakpoint".
    // Enter "-[UIApplication main]" for the Symbol.
    // Choose Action -> "Debugger Command".
    // Enter "expr @import UIKit" for the command.
    // Check "Automatically continue after evaluating actions".
    
UIViewAlertForUnsatisfiableConstraints
    // Helps catch undesirable constraints. Usually, these don't cause obvious visual issues, but they should be fixed since we don't know what could happen in future OS versions.
    // Symbolic breakpoint created by clicking "+" to add breakpoint -> "Symbolic Breakpoint".
    // Enter "UIViewAlertForUnsatisfiableConstraints" for the Symbol.
    
-[UIView(UIConstraintBasedLayout) _viewHierarchyUnpreparedForConstraint:]
    // This is another breakpoint that helps to catch undesirable constraints.
    // Symbolic breakpoint created by clicking "+" to add breakpoint -> "Symbolic Breakpoint".
    // Enter "-[UIView(UIConstraintBasedLayout) _viewHierarchyUnpreparedForConstraint:]" for the Symbol.
    
UICollectionViewFlowLayoutBreakForInvalidSizes
    // Helps catch undesirable constraints in UICollectionViews.
    // Symbolic breakpoint created by clicking "+" to add breakpoint -> "Symbolic Breakpoint".
    // Enter "UICollectionViewFlowLayoutBreakForInvalidSizes" for the Symbol.
```

