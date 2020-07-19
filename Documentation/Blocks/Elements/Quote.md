<h2>`Quote` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Quoted content within a `RichText` block
(line blocks starting with a `>` in Markdown)

If it isn't nested in a `RichText`, it'll automatically create one.

```swift
RichText {
  Quote {
    """
    Nobdy can complain that Catalyst doesn't look like macOS
    if macOS doesn't look like macOS
    """
    Link("@terhechte",
         destination:
         URL("https://twitter.com/terhechte/status/1275129345590341636")
      .italic()
  }
}
```
