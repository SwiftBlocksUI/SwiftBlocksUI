<h2>Actions Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

An block which can contain interactive elements (buttons, select menus,
date pickers).

Example:

```swift
Actions {
  Button(.primary, value: "123") {
    Text("Approve")
  }
}

Docs: https://api.slack.com/reference/block-kit/blocks#actions
