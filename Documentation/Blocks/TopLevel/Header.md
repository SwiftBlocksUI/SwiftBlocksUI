<h2>`Header` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

A simple header text. Very similar to an HTML `H1` tag.

```swift
Header {
  Text("Hello World!")
}
```

- [Slack Documentation](https://api.slack.com/reference/block-kit/blocks#header)


### Blocks API Representation

```json
{
  "type": "header",
  "text": {
    "type": "plain_text",
    "text": "This is a header block",
    "emoji": true
  }
}
```
