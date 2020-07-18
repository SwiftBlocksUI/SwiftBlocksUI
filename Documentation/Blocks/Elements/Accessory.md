<h2>`Accessory` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

An `Accessory` is shown in the upper right of a [`Section`](../TopLevel/Section.md) block.
It is not used in any other block.

There can only be one `Accessory` and the available types are limited to:
- [Images](Image.md)
- [Buttons](Button.md), [DatePickers](DatePicker.md), [Pickers](Picker.md),
  [CheckboxGroups](CheckboxGroup.md)
- overflow menus (not yet available as Blocks)

If the allowed accessory blocks are used within a `Section`, they autowrap themselves
in an `Accessory`. One might still want to use the blocks to make it explicit.

Example:

```swift
Section {
  "Hello World!"
  
  Accessory {
    Image("A cute kitten", url: URL("http://placekitten.com/128/128")!)
  }
}
```

This contains a [`DatePicker`](DatePicker.md) `Accessory` in the 
[`Section`](../TopLevel/Section.md) block:
![block types](https://zeezide.de/img/blocksui/BlockTypes-Annotated.png)

Docs: https://api.slack.com/reference/block-kit/blocks#section
