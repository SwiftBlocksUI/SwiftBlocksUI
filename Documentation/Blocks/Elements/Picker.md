<h2>`Picker` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Blocks to generate various kinds of pickers.

This can generate all kinds of different pickers depending on the
`Selection`. The selection both affects the picker type and whether the
picker is a multiselect picker.

> It is different to a SwiftUI Picker, which is single-select, while this one
> can also do multi selects, similar to a SwiftUI List.<br>
> This also doesn't support PickerStyles, not much styling in BlockKit anyways.

### Examples

Static Options with `.tag`:

```swift
Picker("Importance", selection: $importance,
       placeholder: "Select importance")
{
    "High 💎💎✨".tag("high")
    "Medium 💎"  .tag("medium")
    "Low ⚪️"     .tag("low")
}
```    

Picker on top of [`Identifiable`](https://nshipster.com/identifiable/) objects:

```swift
Picker("Pick Order", orders, selection: $order) { order in
  "\(order.title)"
}
```

Docs: https://api.slack.com/reference/block-kit/block-elements#multi_select


### Model Pickers

If the selection is bound to a `UserID`, `ChannelID` or `ConversationID` (or sets thereof),
specific Slack pickers are generated.

Docs:
- https://api.slack.com/reference/block-kit/block-elements#channel_multi_select
- https://api.slack.com/reference/block-kit/block-elements#conversation_multi_select
- https://api.slack.com/reference/block-kit/block-elements#users_multi_select


A `Picker` ("Select an item") in an [`Actions`](../TopLevel/Actions.md) block:
![block types](https://zeezide.de/img/blocksui/BlockTypes-Annotated.png)
