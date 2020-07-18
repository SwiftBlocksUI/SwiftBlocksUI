<h2>`RichText` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

A block containing formatted and styled content.

Depending on your needs, you might rather want to use a
[`Section`](Section.md).

Note: `RichText` blocks do not seem to be supported with bot tokens,
      they get converted to `Section`s automagically.

RichText's are vertically stacked paragraphs containing formatted `Text`
elements.

There is a fixed set of "sub blocks" they can have:
- `Paragraphs`,   are regular text with styling
- `Preformatted`, are code sections (triple backticks in Markdown)
- `Quotes`,       quoted content
- `List`s (currently not exposed)

```swift
RichText {
  Paragraph {
    "Hello"
    Text("World")
      .bold()
  }
  Preformatted {
    """
    let a = 10
    """
  }
}
```

### [`Paragraph`](../Elements/Paragraph.md)

Styled content within a `RichText` block.

If it isn't nested in a `RichText`, it'll automatically create one.

```swift
RichText {
  Paragraph {
    "Hello"
    Text("World")
      .bold()
  }
}
```

### [`Preformatted`](../Elements/Preformatted.md)

Preformatted ("triple-quote") content within a `RichText` block.
If it isn't nested in a `RichText`, it'll automatically create one.

```swift
Preformatted {
  """
  let a = 10
  """
}
```

### [`Quote`](../Elements/Quote.md)

Quoted content within a `RichText` block.

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
