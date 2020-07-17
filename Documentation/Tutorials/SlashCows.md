<h2>SwiftBlocksUI: SlashCows
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Work in Progress. Extract from 
[Instant “SwiftUI” Flavoured Slack Apps](https://www.alwaysrightinstitute.com/swiftblocksui/),
needs adjustments.

TODO:
- Add app setup links
- Adjust content for standalone page
- Fix video

<hr>

This is what we are going to build, 
the `/vaca` slash command which will retrieve nice ASCII cows messages,
and we'll make the cow message itself interactive by adding buttons.

<center>
  <video autoplay="autoplay" controls="controls"
         style="border-radius: 5px; border: 1px solid #EAEAEA; width: 80%;">
    <source src="https://zeezide.de/videos/blocksui/slash-vaca-demo.mov" type="video/mp4" />
    <img src="https://www.alwaysrightinstitute.com/images/blocksui/client-slash-vaca-4-buttons.png" />
    Your browser does not support the video tag.
  </video>
</center>

### Xcode Project Setup

To get going, we need to create an Xcode tool project and
add the
[SwiftBlocksUI](https://github.com/SwiftBlocksUI/SwiftBlocksUI.git)
and
[cows](https://github.com/AlwaysRightInstitute/cows.git)
package dependencies.

> All this can be done with any editor on any platform,
> the app even runs as a single file shell script via swift-sh!

Startup Xcode, select "New Project" and then the "Command Line Tool" template:
<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/xcode-1-cmdline-tool-cut.png" />
</center>

Give the project a name (I've choosen "AvocadoToast") and save it wherever
you like. Then select the project in the sidebar, and choose the
"Swift Packages" option and press the "+" button:
<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/xcode-4-pkgs-empty-marked-up.png" />
</center>

In the upcoming package browser enter the SwiftBlocksUI package URL:
"`https://github.com/SwiftBlocksUI/SwiftBlocksUI.git`".
<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/xcode-5-pkgs-swiftblocksui-cut.png" />
</center>

In the following dialog which lists the contained products,
you can choose all you want, but `SwiftBlocksUI` is the one required:
<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/xcode-6-pkgs-product-cut.png" />
</center>

> SwiftBlocksUI is the module which brings all the others together.
> They can also be used individually.

Repeat the process to add the
[cows](https://github.com/AlwaysRightInstitute/cows.git)
package, using this url:
`https://github.com/AlwaysRightInstitute/cows.git` 
(one can also just search for "cows" in that panel).

Xcode project ✅

### App Boilerplate and First Cow

Replace the contents of the `main.swift` file with this Swift code:

```swift
#!/usr/bin/swift sh
import cows          // @AlwaysRightInstitute ~> 1.0.0
import SwiftBlocksUI // @SwiftBlocksUI        ~> 0.8.0

dotenv.config()

struct Cows: App {
  
  var body: some Endpoints {
    Group { // only necessary w/ Swift <5.3
      Use(logger("dev"),
          bodyParser.urlencoded(),
          sslCheck(verifyToken(allowUnsetInDebug: true)))

      Slash("vaca", scope: .userOnly) {
        "Hello World!"
      }
    }
  }
}
try Cows.main()
```

It declares the `Cows` app, 
it configures some common middleware (not strictly required)
and declares the `/vaca` slash command endpoint.

Start the app in Xcode and 
going back to your development workspace, send the `/vaca` message:

<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/client-slash-vaca-1-hello-info.png" 
       style="border-radius: 5px; border: 1px solid #EAEAEA; width: 50%;">
</center>

If the stars align, it will show:

<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/client-slash-vaca-1-hello-result.png" 
       style="border-radius: 5px; border: 1px solid #EAEAEA; width: 50%;">
</center>

> If it fails, most likely your tunnel configuration is not working.
> Try whether you can access the URLs you configured in the Slack
> app configuration from within Safari (or curl for that matter).
> Maybe you restarted the free ngrok version and the URLs are different now?

But we didn't came here for "Hello World" but for ASCII cows!
The excellent `cows` module is already imported and it provides a
`vaca` function which returns a random ASCII cow as a Swift String:
```swift
Slash("vaca", scope: .userOnly) {
  Preformatted {
    cows.vaca()
  }
}
```
This introduces the
[`Preformatted`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Blocks/TopLevel/RichText.swift#L46)
blocks. 
It makes sure that the cows are properly rendered in a monospace font
(the same thing you get with triple-backticks in Markdown).
Restart the app and again send the `/vaca` command:
<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/client-slash-vaca-2-random.png" 
       style="border-radius: 5px; border: 1px solid #EAEAEA; width: 35%;">
</center>

That is a proper cow, she even says so! Send `/vaca` as often as you like,
you'll always get a new random cow ...

To summarize:
1. Earlier we configured the `vaca` Slash command in the Slack 
   [Admin Panel](https://api.slack.com/apps)
   and assigned the name `vaca` to it. And we provided our (tunneled) endpoint 
   URL.
2. In the source we declared our `Cows`
   [App](https://github.com/Macro-swift/MacroApp/blob/develop/Sources/MacroApp/App.swift#L10)
   and started that using the `Cows().main()`.
3. We added a `Slash` endpoint in the `body` of the Cows app,
   which handles requests send by Slack to the `vaca` command.
4. As the body of the Slash endpoint, we used the SwiftUI DSL to
   return a new message in response.
      
### Reusable Cow Blocks

Before adding more functionality, lets move the blocks out of the endpoint.
Into an own reusable `CowMessage` blocks.
```swift
struct CowMessage: Blocks {
  var body: some Blocks {
    Preformatted {
      cows.vaca()
    }
  }
}
```
This way we can use our `Cow` struct in other endpoints. 
Or as a child block in other, larger blocks. 
The new Slash endpoint:
```swift
Slash("vaca", scope: .userOnly) { CowMessage() }
```

> Like in SwiftUI it is always a good idea to put even small Blocks into
> own reusable structs early on. 
> Those structs have almost no runtime overhead.


### Request Handling

Something that would be cool is the ability to search for cows,
instead of always getting random cows.
We'd type say `/vaca moon`, and we'd get a moon-cow.
To do this, we need to get access to the content of the slash command message.
This is achieved using a SwiftUI
[EnvironmentKey](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/GenericSwiftUI/Environment/EnvironmentKey.swift#L9),
[`messageText`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Environment/BlocksEnvironment.swift#L121):
```swift
struct CowMessage: Blocks {
  
  @Environment(\.messageText) private var query
  
  private var cow : String {
    return cows.allCows.first(where: { $0.contains(query) })
        ?? cows.vaca()
  }
  
  var body: some Blocks {
    Preformatted {
      cow
    }
  }
}
```

The 
[@Environment](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Environment/Environment.swift#L9)
propery wrapper fills our `query` property with the
[`messageText`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Environment/BlocksEnvironment.swift#L121):
value in the active environment. 
Since `messageText` is already declared as String, there is no need to provide 
an explicit type.

> The environment is prefilled by the endpoints. 
> With relevant Slack context data,
> like the `messageText` as shown, the `user` who sent the request,
> what channel it is happening in and more.<br>
> Like in SwiftUI, own environment keys can be used and they stack just like
> in SwiftUI. One could even adjust a rule engine like
> [SwiftUI Rules](/swiftuirules/)
> to work on top.

Then we have the computed `cow` property, which returns the ASCII cow to be
used. It tries to search for a cow which contains the `query` string, and if
it doesn't find one, returns a random cow
(enhancing the search is left as a readers exercise).

Finally the `body` property, which is required by the
[`Blocks`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Blocks/Blocks.swift#L11)
protocol. It just returns the `cow` in a code block (`Preformatted`).

> Unlike in SwiftUI which requires the `Text` view to embed strings,
> [`String` is declared to be Blocks](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Blocks/Elements/Text.swift#L13)
> in SwiftBlocksUI.
> This seemed reasonable, because Slack content is often text driven.
> The 
> [`Text`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Blocks/Elements/Text.swift#L24)
> blocks also exist, if things shall be explicit.

Sending the `/vaca moon` message now returns a proper co<i>w</i>smonaut:
<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/client-slash-vaca-3-search.png" 
       style="border-radius: 5px; border: 1px solid #EAEAEA; width: 40%;">
</center>


### Interactive Message Content

All this slash-commanding still produced static messages.
Let's make them dynamic by adding a few buttons!

```swift
var body: some Blocks {
  Group { // only Swift <5.3
    Preformatted {
      cow
    }

    Actions {
      Button("Delete!") { response in
        response.clear()
      }
      .confirm(message: "This will delete the message!",
               confirmButton: "Cowsy!")
    
      Button("More!") { response in
        response.push { self }
      }
      Button("Reload") { response in
        response.update()
      }
    }
  }
}
```

The `Group` is only necessary in Swift 5.2 (Xcode 11), starting with 5.3
(Xcode 12beta) `body` is already declared as a `Blocks` builder proper.

We add an 
[`Actions`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Blocks/TopLevel/Actions.swift#L9)
block with the buttons.
We wouldn't have to explicitly wrap the 
[`Buttons`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Blocks/Elements/Button.swift#L12)
in one, w/o they would stack vertically 
(they would autowrap in individual `Actions` blocks). 
`Actions` blocks lay them out horizontally.

The delete button has a 
[confirmation dialog](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Modifiers/ConfirmationDialogModifier.swift#L41)
attached, which is shown by the client before the action is triggered in our app
(it is a client side confirmation, just like the ages old HTML/JS
 [confirm](https://developer.mozilla.org/en-US/docs/Web/API/Window/confirm)
 function).
 
#### Actions

But the new thing we haven't seen before is that the
[action](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Blocks/Action.swift#L79)
closure attached to the `Button` has a 
[`response` parameter](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Blocks/Action.swift#L9):
```swift
Button("More!") { response in
  response.push { self }
}
```
The parameter is entirely optional - if none is used,
`response.end` is called right after the action closure finishes.

**Important**:
If a response parameter is used, the action **must** call one of the provided
response functions. 
It doesn't have to do so right away, an action with a response is 
_asynchronous_.
E.g. it could call into an external system and only when this succeeds decide
on how to respond.

The options are:
- `end`: Close the active view in modal dialog (not necessarily the whole 
  thing), does nothing for interactive messages.
- `clear`: This will close a modal dialog, or delete the originating message
- `update`: Refreshes the a dialog or the current message
- `push`: For dialogs this pushes a new view on the dialog page stack,
  for messages it creates a new message in the same place as the origin.

> After finishing the response using one of the operations,
> an action can still do other stuff.
> E.g. it could schedule `setTimeout` and do something extra later.
> Imagine a "respond in 30 seconds or I'll self-destroy". Entirely possible!<br>
> This is especially important for actions which need to run for longer than
> 3 seconds, which is the Slack timeout for responses. They can just `end`
> the response right away and send a response message later (e.g. as a DM to
> the user).

Our finished cows app:

<center>
  <video autoplay="autoplay" controls="controls"
         style="border-radius: 5px; border: 1px solid #EAEAEA; width: 80%;">
    <source src="https://zeezide.de/videos/blocksui/slash-vaca-demo.mov" type="video/mp4" />
    <img src="https://www.alwaysrightinstitute.com/images/blocksui/client-slash-vaca-4-buttons.png" />
    Your browser does not support the video tag.
  </video>
</center>

The full single-file source suitable for 
[swift-sh](https://github.com/mxcl/swift-sh)
(as [GIST](https://gist.github.com/helje5/7039697515597e31f7e373bd7ce72ce4)):

```swift
#!/usr/bin/swift sh
import cows          // @AlwaysRightInstitute ~> 1.0.0
import SwiftBlocksUI // @SwiftBlocksUI        ~> 0.8.0

dotenv.config()

struct CowMessage: Blocks {
  
  @Environment(\.messageText) private var query
  
  private var cow : String {
    return cows.allCows.first(where: { $0.contains(query) })
        ?? cows.vaca()
  }
  
  var body: some Blocks {
    Group { // only Swift <5.3
      Preformatted {
        cow
      }

      Actions {
        Button("Delete!") { response in
          response.clear()
        }
        .confirm(message: "This will delete the message!",
                 confirmButton: "Cowsy!")
        
        Button("More!") { response in
          response.push { self }
        }
        Button("Reload") { response in
          response.update()
        }
      }
    }
  }
}

struct Cows: App {
  
  var body: some Endpoints {
    Group { // only necessary w/ Swift <5.3
      Use(logger("dev"),
          bodyParser.urlencoded(),
          sslCheck(verifyToken(allowUnsetInDebug: true)))

      Slash("vaca", scope: .userOnly) {
        CowMessage()
      }
    }
  }
}
try Cows.main()
```
