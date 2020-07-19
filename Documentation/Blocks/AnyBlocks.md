<h2>`AnyBlocks`
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

A type eraser for (statically typed) `Blocks`.

Can be used to mix & match Blocks of different static types.

Example:
```swift
var activeBlocks : AnyBlocks {
  switch status {
    case "order" : return AnyBlocks(OrderStatus())
    case "home"  : return AnyBlocks(HomePage())
  }
}
var body: some View {
  Section {
    activeBlocks
  }
}
```
