<h2>SwiftBlocksUI
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

SwiftBlocksUI is a way to write interactive Slack messages and modal dialogs
(also known as Slack "applications")
using a SwiftUI like declarative style.

This is what a full application looks like:
```swift
#!/usr/bin/swift sh
import SwiftBlocksUI // @SwiftBlocksUI ~> 0.8.0

dotenv.config()

struct ClipItView: Blocks {

  @State(\.messageText) var messageText
  @State var importance = "medium"
  
  var body: some Blocks {
    View("Save it to ClipIt!") {
      TextEditor("Message Text", text: $messageText)
      
      Picker("Importance", selection: $importance) {
        "High 💎💎✨".tag("high")
        "Medium 💎"  .tag("medium")
        "Low ⚪️"     .tag("low")
      }
      
      Submit("CliptIt") {
        console.log("Clip:", messageText, importance)
      }
    }
  }
}

struct ClipIt: App {

  var body: some Endpoints {
    Use(logger("dev"), bodyParser.urlencoded(),
        sslCheck(verifyToken(allowUnsetInDebug: true)))
        
    MessageAction("clipit") {
      ClipItView()
    }
  }
}

try ClipIt.main()
```


## Documentation

There is a related blog entry going over SwiftBlocksUI:
[Instant “SwiftUI” Flavoured Slack Apps](https://www.alwaysrightinstitute.com/swiftblocksui/).

Additional documentation is going to arrive within this repository:
[Documentation](Documentation/README.md).


## Environment Variables

- `PORT` (the port the app is going to start on, defaults to 1337)
- `macro.core.numthreads`
- `macro.core.iothreads`
- `macro.core.retain.debug`
- `macro.concat.maxsize`
- `macro.streams.debug.rc`
- `macro.router.debug`
- `macro.router.matcher.debug`


## Requirements

On Linux this currently requires a Swift 5.3 environment
(swiftc crash, might be [SR-12543](https://bugs.swift.org/browse/SR-12543)).

On macOS it should work with Swift 5.2 (aka Xcode 11) and up,
though 5.3 has some additional conveniences.


### Links

- [Macro](https://github.com/Macro-swift/Macro/)

### Who

**SwiftBlocksUI** is brought to you by
the
[Always Right Institute](http://www.alwaysrightinstitute.com)
and
[ZeeZide](http://zeezide.de).
We like 
[feedback](https://twitter.com/ar_institute), 
GitHub stars, 
cool [contract work](http://zeezide.com/en/services/services.html),
presumably any form of praise you can think of.
