<h2>`Section` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

A very flexible top-level block that can contain formatted text,
fields and an interactive accessory view.

The core structure of this block is the main text which can contain
markdown styled content.

As an extra this can show an image or an interactive element (e.g. a
DatePicker in the upper right).

Finally it can contain "fields", which is textual content that will be
layed out in a two column grid below the main text.

```swift
Section {
  Text("Hello World!")
    .bold()
  
  Field {
    Text("Style:").bold()
  }
  Field {
    Text("Bold)
  }
}
```

With Accessory:
```swift
Section {
  "Hello World!"
  Accessory {
    Image("A cute kitten",
          url: URL("http://placekitten.com/128/128")!)
  }
}
```

![Block Types](https://zeezide.de/img/blocksui/BlockTypes-Annotated.png)

- [Slack Documentation](https://api.slack.com/reference/block-kit/blocks#section)



### Blocks API Representation

```json
{
  "type"      : "section",
  "text"      : {
    "type" : "mrkdwn",
    "text" : "This is a section block with a button."
  },
  "accessory" : {
    "type"      : "button",
    "value"     : "click_me_123",
    "action_id" : "button-action",
    "text"      : { "type": "plain_text", "text": "Click Me", "emoji": true }
  }
}
```
