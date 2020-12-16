<h2>SwiftBlocksUI: Technology Overview
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

### Slack "Block Kit"

In February 2019 Slack 
[introduced](https://medium.com/slack-developer-blog/block-party-d72c70a01911) 
the new
"[Block Kit](https://api.slack.com/block-kit)",
an "easier way to build powerful apps".
Before Block Kit, Slack messages were composed of a trimmed down 
[markdown](https://www.markdownguide.org/tools/slack/) message text
and an optional set of 
"[attachments](https://api.slack.com/messaging/composing/layouts#attachments)"
(the attachments not being files, but small "widget blocks" with a fixed,
predefined layout).

Block Kit goes away from those simple text chat "markdown messages" 
to a message representation which is a little like HTML 1.0 
(actually more like 
 [WML](https://en.wikipedia.org/wiki/Wireless_Markup_Language)), 
but encoded in 
[JSON](https://en.wikipedia.org/wiki/JSON).
Instead of just styling a single text, one can have multiple paragraphs,
images, action sections, input elements, buttons and more.

Slack provides the 
[Block Kit Builder](https://app.slack.com/block-kit-builder/)
web app which is a great way to play with the available blocks.
**This is a message** (not a dialog):
```json
[ { "type": "section",
    "text": {
      "type": "mrkdwn",
      "text": "Pick a date for the deadline."
    },
    "accessory": {
      "type": "datepicker",
      "initial_date": "1990-04-28",
      "placeholder": {
        "type": "plain_text",
        "emoji": true,
        "text": "Select a date"
      }
    }
  }
]
```

Produces:
<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/builder-datepicker.png" 
       style="border-radius: 5px; border: 1px solid #EAEAEA; width: 75%;">
</center>


In SwiftBlocksUI one doesn't have to deal with those low level JSON
representations, "Blocks" will generate it.
The above as 
[Blocks](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Blocks/Blocks.swift#L11)
declarations:
```swift
Section {
  "Pick a date for the deadline."
  Accessory {
    DatePicker("Select a date", selection: $date)
  }
}
```

The key thing to understand is that Slack "messages" are not simple chat
style text(/markdown) messages anymore.
They are more like like small web pages, with form elements,
which can be updated by an application.<br>
And those "web widgets" are built using "Blocks JSON", 
hence the name "SwiftBlocksUI".

### Slack "Applications"

It's a little confusing when Slack talks about
["applications"](https://slack.com/apps),
which even have an AppStore like catalog.
It makes you think of iOS apps, but they aren't anything like that.

Slack "applications" are HTTP servers, i.e. "web applications".
They can send content (HTML, in this case blocks JSON) 
to the Slack client if it requests it
(using a Shortcut or Slash command).
Unlike HTTP servers, they can also proactively _push_ content
(interactive messages) into the client. 
For example based on time (11:45am lunch message with inline ordering controls),
or when an event occurs in some external system 
(say SAP purchase order approved).

> A common misconception is that Slack applications run as little JavaScript
> snippets within the Electron client application. 
> This is (today) **not** the case.
> The Slack client doesn't even contact the app directly, but always only
> through the Slack servers as a negotiator making sure the app is legit.

There are two parts to a Slack application:
1. The HTTP endpoint(s) run by the developer, i.e. the implementation
   of the application (in our case using SwiftBlocksUI).
2. The definition of the application which has to be done within
   the [Slack Admin UI](https://api.slack.com/apps),
   this includes the permissions the app will have
   (represented by a Slack API token),
   and the Shortcuts, Message Actions and Slash Commands it provides.

One starts developing an application in an own Slack workspace,
but they can be (optionally) configured for deployment in any Slack workspace
(and even appear in the Slack application catalog, 
 with "Install MyApp" buttons).

> Writing 2020 Slack applications feels very similar to the 
> ~1996 Netscape era of the web.
> The Slack client being the Netscape browser and the applications being
> HTTP apps hosted on an Netscape Enterprise Server.<br>
> The apps can't do very much yet 
> (they are not in the AJAX/Web 2.0 era just yet),
> but they are way more powerful than oldskool dead text messages.<br>
> Also - just like in Web 1.0 times - 🍕 ordering is the demo
> application 👴

As mentioned the Slack
[documentation](https://api.slack.com/interactivity/handling#payloads)
on how to write applications is awesome.
But the mechanics to actually drive an app involves a set of endpoints and
response styles (response URLs, trigger IDs, regular web API posts).<br>
SwiftBlocksUI consolidates those into a single, straightforward API.
Abstracted away in
[Macro.swift](https://github.com/Macro-swift/) 
middleware, like this endpoint definition from the example above:

```swift
MessageAction("clipit") {
  ClipItView()
}
```

> Things shown here are using
> [MacroApp](https://github.com/Macro-swift/MacroApp)
> declarative middleware endpoints.
> The module below SwiftBlocksUI (BlocksExpress) also supports
> "Node.js middleware" style: `express.use(messageAction { req, res ...})`.


### Apple's SwiftUI

If you found this page, you probably know basic
[SwiftUI](https://developer.apple.com/xcode/swiftui/)
already.
If you don't, those WWDC sessions are good introductions:
[Introducing SwiftUI](https://developer.apple.com/videos/play/wwdc2019/204/) and
[SwiftUI Essentials](https://developer.apple.com/videos/play/wwdc2019/216).<br>
In short SwiftUI is a new UI framework for Apple platforms which allows
building user interfaces declaratively.

SwiftUI has that mantra of
“[Learn once, use anywhere](https://developer.apple.com/videos/play/wwdc2019/216)”
(instead of
 “[Write once, run anywhere](https://en.wikipedia.org/wiki/Write_once,_run_anywhere)”).
<br>
SwiftBlocksUI does not allow you to take a SwiftUI app 
and magically deploy it as a Slack application.
But it does try to reuse many of the concepts of a SwiftUI application,
how one composes ("declares") blocks, 
the concept of an environment (i.e. dependency injection),
even `@State` to some degree.

Differences, there are many. 
In SwiftUI there is a tree of `Views`.
While Blocks also have a (different) concept of `Views` 
(a container for modal or home tab content),
Slack Block Kit blocks aren't nested but just a "vstack" of blocks.

#### Basic Structure

A simple example which could be used within a modal dialog:
```swift
struct CustomerName: Blocks {      // 1
  
  @State var customerName = ""     // 2
  
  var body: some Blocks {          // 3
    TextField("Customer Name",     // 4
              text: $customerName) // 5
  }
}
```

1. User Interfaces are defined as Swift `struct`s which conform to the
   [`Blocks`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Blocks/Blocks.swift#L11), 
   protocol. You can reuse those structs in other structs and
   thereby reuse UIs which have similar looks.
2. Properties can be annotated with 
   "[property wrappers](https://www.vadimbulavin.com/swift-5-property-wrappers/)".
   In this case it is an `@State` which is required so that the value
   sticks while the Blocks structs get recreated during API request
   processing (the do not persist longer!).
3. The sole requirement of the `Blocks` protocol is that the struct has a
   `body` property which returns the nested blocks.
   The special `some` syntax is used to hide the real (potentially long) 
   generic type.
4. The builtin 
   [`TextField`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Blocks/Elements/TextField.swift#L13), 
   Blocks is used to produce a plain text input field,
   a `TextField` can be two-way. That is send an initial value to the client,
   and also push a value send by the client back into the Blocks struct.
5. To be able to push a value back into the `customerName` property,
   SwiftBlocksUI uses a
   [`Binding`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/GenericSwiftUI/Binding/Binding.swift#L9),
   which can be produced using the `$` syntax on the `@State` wrapper.
   Bindings can nest, e.g. `$store.address.street` works just fine.

Note how it's always the plural `Blocks`. That got chosen because those `Blocks`
structs are used to build a set of API blocks (instead of a single "View").


#### Block Nesting

A special thing in SwiftBlocksUI is that it can synthesize a valid Block Kit
structure. For example, Block Kit requires this structure to setup a TextField:
```swift
View {
  Input {
    TextField("title", text: $order.title)
  }
}
```
In SwiftBlocksUI just the TextField is sufficient, it'll auto-wrap:
```swift
TextField("title", text: $order.title)
```

As mentioned, Block Kit blocks do not nest. This Section-in-Section is invalid:
```swift
Section {
  "Hello"
  Section { // invalid nesting
    "World"
  }
}
```
SwiftBlocksUI will unnest the blocks and print a warning.
