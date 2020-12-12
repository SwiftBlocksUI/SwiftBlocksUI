<h2>`Markdown` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

This element emits
raw [Slack Markdown](https://api.slack.com/reference/surfaces/formatting#basics).

Markdown can be styled:

```swift
Markdown("Price")
  .bold()
```
Will result in
```
*Price*
```

`Markdown` elements can be added together, Strings can be appended:
```swift
Markdown("Price:").bold + Markdown(" 100") + "€"
```
Will result in
```
*Price:* 100€
```
