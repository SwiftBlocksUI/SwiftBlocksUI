<h2>`Context` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Displays images and text in a horizontal stack, in a smaller font.

Show some contextual information, visually distinct to the main message
content.

Example:

```swift
Context {
  Image("Pin", url: URL(
        "https://image.freepik.com/free-photo/red-drawing-pin_1156-445.jpg")!)
  Text("Location: ") + Text("Dogpatch").bold()
}
```

![Block Types](https://zeezide.de/img/blocksui/BlockTypes-Annotated.png)

Docs: https://api.slack.com/reference/block-kit/blocks#context


### Blocks API Representation

```json
{
  "type": "context",
  "elements": [
    { "type" : "mrkdwn",
      "text" : "*This* is :smile: markdown"
    },
    { "type"      : "image",
      "alt_text"  : "cute cat"
      "image_url" : "https://pbs.twimg.com/profile_images/625633822235693056/lNGUneLX_400x400.jpg"
    },
    { "type": "plain_text",
      "text": "Author: K A Applegate",
      "emoji": true
    }
  ]
}
```
