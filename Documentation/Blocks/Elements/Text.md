<h2>`Text` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Regular, inline text, sometimes used to fill specific text fields of other elements.

In SlackBlocksUI Swift `Strings` can be used directly as Blocks.

Texts can be styled:

```swift
Text("Price")
  .bold()
```

Text can be added together:
```swift
Text("Price:").bold + Text("100")
```

Foundation Localization can be used to generate localized Texts,
and Foundation Formatters can be used to format content:

```swift
Text(123.22, formatter: NumberFormatter())
```
