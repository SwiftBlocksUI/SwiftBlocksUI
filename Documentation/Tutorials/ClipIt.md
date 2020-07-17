<h2>SwiftBlocksUI: ClipIt!
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Work in Progress. Extract from 
[Instant “SwiftUI” Flavoured Slack Apps](https://www.alwaysrightinstitute.com/swiftblocksui/),
needs adjustments

TODO:
- Add app setup links
- Adjust content for standalone page
- Fix video

<hr>

Loosely based on the official Slack tutorial:
[Make your Slack app accessible directly from a message](https://api.slack.com/tutorials/message-action).

What we want to do here is work on some arbitrary message the user selects.
This is possible using "Message Actions" 
(called "Message Shortcuts" in the admin panel).
We already configured a "Message Shortcut" tied to the "clipit" callback-id 
above, let's bring it to life.

It is already showing up in the message context menu:

<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/client-clipit-menu-markup.png" 
       style="border-radius: 8px; border: 1px solid #EAEAEA; width: 75%;">
</center>

The dialog we want to show:
```swift
struct ClipItForm: Blocks {

  @State(\.messageText) var messageText
  @State var importance = "medium"
  
  private func clipIt() {
    console.log("Clipping:", messageText, 
                "at:", importance)
  }
  
  var body: some Blocks {
    View("Save it to ClipIt!") {
      TextEditor("Message Text", text: $messageText)
      
      Picker("Importance", selection: $importance,
             placeholder: "Select importance")
      {
        "High 💎💎✨".tag("high")
        "Medium 💎"  .tag("medium")
        "Low ⚪️"     .tag("low")
      }
      
      Submit("CliptIt", action: clipIt)
    }
  }
}
```

And the endpoint:
```swift
MessageAction("clipit") {
  ClipItForm()
}
```

There isn't anything new in here 
(<span style="font-size: 0.5em;">the attentive reader may spot a tiny specialty</span>).
We use the `\.messageText` environment to get access to the
message we work on (similar to the Slash command in the Cows app).
There is a multiline `TextField` which is filled with the message text.
And a 
[`Picker`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Blocks/Elements/Picker/Picker.swift#L11) 
plus a `Submit` button. Done.

<center>
  <video autoplay="autoplay" controls="controls"
         style="border-radius: 5px; border: 1px solid #EAEAEA; width: 80%;">
    <source src="https://zeezide.de/videos/blocksui/clipit-demo.mov" type="video/mp4" />
    Your browser does not support the video tag.
  </video>
</center>

And with this, we'd like to close for today.
