<h2>`Button` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Buttons come in many forms and styles. They can have an `Action` attached
if the Blocks are used as an Endpoint.

There are also special-purpose buttons: `Submit` and `Cancel` which are
used in combination w/ View Submissions.

Example:

```swift
Actions {
  Button("Approve", .primary, value: "123")
}
```

Example with nested Text:

```swift
Actions {
  Button(.primary, value: "123") {
    Text("Approve")
  }
}
```

Example with Link:

```swift
Actions {
  Button(.primary, value: "123") {
    Link("Apple.com", destination: URL("https://apple.com")!)
  }
}
```

Example with Confirmation:
    
```swift
Actions {
  Button(.primary, value: "123") {
    Link("Apple.com", destination: URL("https://apple.com")!)
  }
  .confirm(message: "Do you really want to go to Apple.com?!",
           style: .danger)
}
```

### Submit Buttons

There are also special `Submit` and `Cancel` buttons which are used in combination
with [`View`](../TopLevel/View.md) submissions.
Those buttons do not result in actualy buttons, but will the respective values of the View.


This contains a `Button` in an [`Actions`](../TopLevel/Actions.md) block:
![block types](https://zeezide.de/img/blocksui/BlockTypes-Annotated.png)

Docs: https://api.slack.com/reference/block-kit/block-elements#button


### Blocks API Representation

```json
{
  "type"      : "button",
  "value"     : "click_me_123",
  "action_id" : "actionId-2",
  "text"      : { "type": "plain_text", "text": "Click Me", "emoji": true }
}
```

