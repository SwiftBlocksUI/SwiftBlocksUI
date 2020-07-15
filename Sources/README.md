#  Package Structure

This contains five libraries:

- [SlackBlocksModel](SlackBlocksModel/README.md)
- [SlackClient](SlackClient/README.md)
- [Blocks](Blocks/README.md)
- [BlocksExpress](BlocksExpress/README.md)
- [SwiftBlocksUI](SwiftBlocksUI/README.md)

The `SlackBlocksModel` library only contains Codable structs to represent the 
Slack API elements, it doesn't even have a dependency on `Macro`.

`SlackClient` is just a super tiny library to perform Slack API requests, 
currently built on top of `URLSession`. 
It uses the structures provides by `SlackBlocksModel`, but is also unrelated to
`Macro`.

All the SwiftUI-like logic is contained in `Blocks`. Blocks function builders, 
environments, rendering, all that is in here.
It is stacked just on top of just `SlackBlocksModel`, it doesn't use 
`SlackClient` nor `Macro`.
It uses `swift-log` for some minor logging and it uses `CNIOSHA1` from NIO to 
generate hashes (which is a little wonky, there are also `Crypto` 
implementations available).

`BlocksExpress` enhances `MacroExpress` so that `Blocks` can be used to build
Slack middleware. One can send blocks, and there is Middleware to parse incoming
requests.
One can build full, "declarative" UI, Slack apps using just `BlocksExpress`.

Finally `SwiftBlocksUI` provides the sugar on the top. It makes use of 
`MacroApp` to also declare the middleware stack using SwiftUI-like syntax.
