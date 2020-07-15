<h2>Context Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Displays images and text in a vertical stack in a smaller font.

Show some contextual information, visually distinct to the main message
content.

Example:

```swift
Context {
  Image("Pin", url: URL(
        "https://image.freepik.com/free-photo/red-drawing-pin_1156-445.jpg")!)
  Text("Location: ") + Text("Dogpatch").bold()
}
```

Docs: https://api.slack.com/reference/block-kit/blocks#context
