<h2>Button Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Encode a "button" element.

Buttons come in many forms and styles. They can have an `Action` attached
if the Blocks are used as an Endpoint.

There are also special-purpose buttons: `Submit` and `Cancel` which are
used in combination w/ View Submissions.

Example:

```swift
Actions {
  Button("Approve", .primary, value: "123")
}
```

Example with nested Text:

```swift
Actions {
  Button(.primary, value: "123") {
    Text("Approve")
  }
}
```

Example with Link (TOD):

```swift
Actions {
  Button(.primary, value: "123") {
    Link("Apple.com", destination: URL("https://apple.com")!)
  }
}
```

Example with Confirmation (TODO):
    
```swift
Actions {
  Button(.primary, value: "123") {
    Link("Apple.com", destination: URL("https://apple.com")!)
    Confirmation(style: .danger) {
      Text("Do you really want to go to Apple.com?!")
    }
  }
}
```

Docs: https://api.slack.com/reference/block-kit/block-elements#button
