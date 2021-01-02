<h2>`TextField` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

A Plain-text input element.

`TextField`'s are only valid in modals, within [`Input`](../TopLevel/Input.md) blocks!
I.e. they can't be used within [`Actions`](../TopLevel/Actions.md) or as a 
`Section` [`Accessory`](Accessory.md).

[`Formatter`](https://developer.apple.com/videos/play/wwdc2020/10160/)
objects can be used to format, parse and validate values. If a
formatter fails to parse a value, and error will be returned for the
view submission (and shown to the user by the client).

Example with implicit [`Input`](../TopLevel/Input.md):
```swift
View {
  TextField("Lastname", text: $person.lastName)
}
```

Example with explicit [`Input`](../TopLevel/Input.md):
```swift
View {
  Input(hint: "Hello World!", optional: true) {
    TextField("Lastname", text: $person.lastName)
  }
}
```

Example with [`Formatter`](https://developer.apple.com/videos/play/wwdc2020/10160/):
```swift
TextField("Amount", value: $amount,
          formatter: NumberFormatter())
```

`TextField` with a specific length:
```swift
TextField("Password", text: $person.lastName)
  .length(3...10)
```

Docs: https://api.slack.com/reference/block-kit/block-elements#input


### Blocks API Representation

```json
{
  "type"      : "plain_text_input",
  "action_id" : "plain_text_input-action"
}
```
