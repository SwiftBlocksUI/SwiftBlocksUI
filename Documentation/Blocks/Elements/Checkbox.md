<h2>`Checkbox` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Alias: `Toggle`

Blocks to generate a single `Checkbox`. Although they can autowrap themselves in one,
it is usually better to explicitly wrap them in a
[`CheckboxGroup`](CheckboxGroup.md) to give the set a title.

Technically `Checkbox` elements generate API "options" just like 
[`Picker`](Picker.md) [`Options`](Option.md).

But they have different semantics at the Blocks level, e.g. an explicit
binding (while the `Picker` itself maintains the selection).

Important: Modal / Hometab only (within Views), not in messages!

Example:
```swift
CheckboxGroup("Please select desirable restaurants:") {
  Checkbox("Café Macs",   isOn: $restaurants.macs)
  Checkbox("Chez TJ",     isOn: $restaurants.chez)
  Checkbox("Alexander's", isOn: $restaurants.alex)
}
```

Example targetting an `OptionSet` (works on all `Set`s):

```swift
CheckboxGroup("Please select desirable restaurants:") {
  Checkbox("Café Macs",   selection: $restaurants, .macs)
  Checkbox("Chez TJ",     selection: $restaurants, .chez)
  Checkbox("Alexander's", selection: $restaurants, .alex)
}
```

Docs: https://api.slack.com/reference/block-kit/block-elements#checkboxes
