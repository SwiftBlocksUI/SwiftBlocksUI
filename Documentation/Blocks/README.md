<h2>SwiftBlocksUI
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Work in Progress.

`Blocks` is what a `View` is in SwiftUI.

Unlike SwiftUI `View`s, Slack blocks cannot be arbitrarily nested, but rather 
have a very specific structure: an array of `Block` elements.
This is why I called the "Builders" as returning the plural `some Blocks` (the 
result is always an array of API blocks).

The `Blocks` builder structures can be mixed more freely than the resulting 
Slack blocks, e.g. you can do a simple:

    Text("🥑 Toast")

And it will synthesize the necessary surrounding blocks, such as:

    RichText {
      Paragraph {
        Text("🥑 Toast")
      }
    }

Don't confuse the `Blocks` builders with the actual API elements, they are 
designed to be more convenient than the wire protocol.
