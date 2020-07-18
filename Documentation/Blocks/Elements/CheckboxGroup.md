<h2>`CheckboxGroup` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Blocks to group a set of [`Checkboxes`](Checkbox.md).

The group can have a title which is displayed on top of the checkboxes in bold.

At the JSON API level this is very similar to a [`Picker`](Picker.md), but the semantics
in BlocksUI are different.

Checkout [`Checkbox`](Checkbox.md) for more information.

Important: Modal / Hometab only (within Views), not in messages!

Example:

```swift
CheckboxGroup("Please select desirable restaurants:") {
  Checkbox("Café Macs",   isOn: $restaurants.macs)
  Checkbox("Chez TJ",     isOn: $restaurants.chez)
  Checkbox("Alexander's", isOn: $restaurants.alex)
}
```

Docs: https://api.slack.com/reference/block-kit/block-elements#checkboxes
