#  SwiftBlocksUI

SwiftBlocksUI uses SwiftUI concepts to declare and drive Slack
[Block Kit](https://api.slack.com/block-kit)
based interactive messages and modals.

SwiftBlocksUI builds on top of `BlocksExpress`, `SlackClient` and the core `Blocks`.

> Swift 5.3 note: `body` is automatically marked as a BlocksBuilder starting with Swift 5.3,
> In Swift 5.2 multiple blocks in the `body` need to be nested in a `Group`, or explicitly
> mark `body` as a `@BlocksBuilder`.
> Also `@main` is only available in Swift 5.3+, just call `.main()` in older versions.

## Differences to SwiftUI

### View

The pair to SwiftUI's `View` protocol is `Blocks` in SwiftBlocksUI. It is in plural, because
a set of those blocks are generated (instead of a tree like node which can have children).

There is no separate `ViewModifier` concept, `Blocks` are usually simple.

> The is also a `Block` in the `SlackBlocksModel` module. That is a the raw API type,
> not a higher level element.

To make it even more confusing, Block Kit also has a concept call "Views".
Those are essentially "pages" in a modal dialog. In SwiftBlocksUI they are
represented as `Blocks`.

### State

The `@State` in SwiftBlocksUI is **not** long living. State is used to preserve processing
state while Blocks go through the three phases: takeValues, invokeAction and render.
And is lost thereafter.

The `@MetaData` wrapper can be used in _Views_ to attach some long living state to
Views.


## Endpoints

It makes use of `MacroApp` to also declare the middleware stack using SwiftUI-like syntax.
It is just a fancy wrapper around the middleware provided by `BlocksExpress`.

### Middleware: `interactiveBlocks`

A special thing is that `Blocks` can be actual endpoints and deal with all the different
Slack endpoints "styles". 
This is handled by the `interactiveBlocks` middleware (which takes Blocks as an
argument).
`Blocks` as endpoints will push values in submissions and push them into the
respective properties, and invoke "action" blocks.
