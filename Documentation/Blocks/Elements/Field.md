<h2>`Field` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Encode a [`Section`](../TopLevel/Section.md) "field". Fields 
are shown in a two column layout.

Example:

```swift
Section {
  Text("Hello World!")
  Field {
    Text("Style:").bold()
  }
  Field {
    Text("Bold)
  }
}
```

This contains four `Fields` in the [`Section`](../TopLevel/Section.md) block
(price/high, popularity/high):
![block types](https://zeezide.de/img/blocksui/BlockTypes-Annotated.png)
