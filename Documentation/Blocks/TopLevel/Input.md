<h2>`Input` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

`Input` blocks are only valid in modals. Unlike you might expect, an
Input only holds a single element 
(e.g. a 
[`TextField`](../Elements/TextField.md), 
a [`DatePicker`](../Elements/DatePicker.md),
or one of the Pickers/Menus.

It annotates that `TextField` with required extra information like a label
and a hint.
Quite often you don't explicitly need to specify an `Input` in your Blocks,
just using a `TextField` will automatically wrap the Input around.

Example:

```swift
View {
  Input(hint: "Hello World!") {
    TextField("Title", text:$title)
  }
}
```

Docs: https://api.slack.com/reference/block-kit/blocks#input


### Blocks API Representation

```json
{
  "type"            : "input",
  "dispatch_action" : true,
  "element": {
    "type"      : "plain_text_input",
    "action_id" : "plain_text_input-action"
  },
  "label": { "type": "plain_text", "text": "Label", "emoji": true }
}
```
