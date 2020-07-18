<h2>`Actions` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

A block which can contain interactive elements 
([Buttons](../Elements/Button.md), 
 [Pickers](../Elements/Picker.md), 
 [DatePickers](../Elements/DatePicker.md)).

The elements are rendered horizontally (as if they are in a VStack).

Example:

```swift
Actions {
  Button(.primary, value: "123") {
    Text("Approve")
  }
}
```

![Block Types](https://zeezide.de/img/blocksui/BlockTypes-Annotated.png)

Docs: https://api.slack.com/reference/block-kit/blocks#actions
