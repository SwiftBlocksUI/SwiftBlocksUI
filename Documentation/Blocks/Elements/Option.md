<h2>`Option` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Blocks to generate a single option for a [`Picker`](Picker.md).

Options do not have to be provided explicitly, one can also use [`Links`](Link.md)
or [`Texts`](Text.md) as options within a [`Picker`](Picker.md).

Checkout [`Picker`](Picker.md) for more information.

Explicit options can have a `title`, a `hint` text, even a `URL`.

Example with explicit `Options`:

```swift
Picker("Importance", selection: $importance,
       placeholder: "Select importance")
{
    Option("High 💎💎✨").tag("high")
    Option("Medium 💎")  .tag("medium")
    Option("Low ⚪️")     .tag("low")
}
```

Docs: https://api.slack.com/reference/block-kit/block-elements#multi_select


### Blocks API Representation

In a static Picker:
```json
{
  "type"        : "static_select",
  "action_id"   : "actionId-3",
  "placeholder" : {
    "type": "plain_text", "text": "Select an item", "emoji": true
  },
  "options"     : [
    { "text": {
        "type": "plain_text", "text": "*this is plain_text text*", "emoji": true
      },
      "value": "value-0"
    },
    { "text": {
        "type": "plain_text", "text": "*this is plain_text text*", "emoji": true
      },
      "value": "value-1"
    },
    { "text": {
        "type": "plain_text", "text": "*this is plain_text text*", "emoji": true
      },
      "value": "value-2"
    }
  ]
}
```
