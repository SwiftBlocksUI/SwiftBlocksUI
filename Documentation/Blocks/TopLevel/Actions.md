<h2>`Actions` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

A block which can contain interactive elements 
([Buttons](../Elements/Button.md), 
 [Pickers](../Elements/Picker.md), 
 [DatePickers](../Elements/DatePicker.md)).

The elements are rendered horizontally (as if they are in a VStack).

Example:

```swift
Actions {
  Button(.primary, value: "123") {
    Text("Approve")
  }
}
```

Note that `Actions` cannot contain [TextField](../Elements/TextField.md)s
(i.e. it cannot be used to layout such horizontally).

![Block Types](https://zeezide.de/img/blocksui/BlockTypes-Annotated.png)

Docs: https://api.slack.com/reference/block-kit/blocks#actions


### Blocks API Representation

```json
{
  "type"     : "actions",
  "elements" : [
    { "type"         : "datepicker",
      "initial_date" : "1990-04-28",
      "action_id"    : "actionId-0",
      "placeholder": {
        "type"  : "plain_text",
        "text"  : "Select a date",
        "emoji" : true
      }
    },
    { "type"         : "datepicker",
      "initial_date" : "1990-04-28",
      "action_id"    : "actionId-1"
      "placeholder": {
        "type"  : "plain_text",
        "text"  : "Select a date",
        "emoji" : true
      }
    }
  ]
}
```
