<h2>`Link` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Renders or attaches a hyperlink to content or to a specific element.

- In regular or rich text, this creates a Link run (an inline link in the text).
- When used within [`Buttons`](Button.md), the button's URL is filled with the link.
- When used as a [`Section`](../TopLevel/Section.md) [accessory](Accessory.md) or as a
  top-level [`Actions`](../TopLevel/Actions.md) block child, it becomes a 
  [`Button`](Button.md) with the link's URL.
- When used within a [`Picker`](Picker.md), a `Link` turns into an [`Option`](Option.md).

[`Actions`](../TopLevel/Actions.md) Example:

```swift
Actions {
  Link("Visit ZZ", destination: URL("https://zeezide.de/")!)
}
```

[`Section`](../TopLevel/Section.md) Example:

```swift
Section {
  "Hello, here is an inline link:"
  Link("Visit ZZ", destination: URL("https://zeezide.de/")!)
  
  "And this will show as a button in the upper right:"
  Accessory {
    Link("Visit ZZ", destination: URL("https://zeezide.de/")!)
  }
}
```

[`Buttons`](Button.md) Example:

```swift
Button {
  Link("Visit ZZ", destination: URL("https://zeezide.de/")!)
}
```
