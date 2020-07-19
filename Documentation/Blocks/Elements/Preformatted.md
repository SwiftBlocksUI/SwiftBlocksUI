<h2>`Preformatted` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Preformatted ("triple-quote") content within a
[`RichText`](../TopLevel/RichText.md) or
[`Section`](../TopLevel/Section.md) block.

If it isn't nested in a `RichText`/`Section`, it'll automatically create one.

```swift
Preformatted {
  """
  let a = 10
  """
}
```
