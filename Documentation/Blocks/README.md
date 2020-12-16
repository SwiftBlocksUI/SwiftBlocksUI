<h2>SwiftBlocksUI
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Work in Progress.

<hr>

### Blocks

`Blocks` is what a `View` is in SwiftUI.

Unlike SwiftUI `View`s, Slack blocks cannot be arbitrarily nested, but rather 
have a very specific structure: an array of `Block` elements.
This is why the "Builders" are called as returning the plural `some Blocks` (the 
result is always an array of API blocks).

The `Blocks` builder structures can be mixed more freely than the resulting 
Slack blocks, e.g. you can do a simple:

    Text("🥑 Toast")

And it will synthesize the necessary surrounding blocks, such as:

    RichText {
      Paragraph {
        Text("🥑 Toast")
      }
    }

Don't confuse the `Blocks` builders with the actual API elements, they are 
designed to be more convenient than the wire protocol.

### Available Blocks

#### Top-Level Blocks

Those Blocks build top-level Slack API blocks (`View` being a bit special, it just annotates
the output).

[Input](TopLevel/Input.md) blocks are only allowed in modals (Views).

[Image](Elements/Image.md) blocks can show as a top-level block, or as an image embedded
in some other block (e.g. in `Section` `Accessory`s or `Context`s).

- [Section](TopLevel/Section.md)
- [Actions](TopLevel/Actions.md)
- [Context](TopLevel/Context.md)
- [Divider](TopLevel/Divider.md)
- [Input](TopLevel/Input.md)
- [View](TopLevel/View.md)
- [RichText](TopLevel/RichText.md)

#### Element Blocks

Element blocks can be used at the top-level, they'll auto-wrap themselves in a default
Top-Level block.

- [Text](Elements/Text.md)
- [Link](Elements/Link.md)
- [Image](Elements/Image.md)
- Interactive Elements
  - [Button](Elements/Section.md)
  - [TextField](Elements/TextField.md)
  - [CheckboxGroup](Elements/CheckboxGroup.md)
    - [Checkbox](Elements/Checkbox.md)
  - [Picker](Elements/Picker.md)
    - [Option](Elements/Option.md)
  - [DatePicker](Elements/DatePicker.md)
  - [TimePicker](Elements/TimePicker.md)
- Section Elements
  - [Accessory](Elements/Accessory.md)
  - [Field](Elements/Field.md)
- Rich Text Styling
  - [Paragraph](Elements/Paragraph.md), regular content
  - [Preformatted](Elements/Preformatted.md), triple-backtick markdown style code sections
  - [Quote](Elements/Quote.md), `>` indented quote content
- [Markdown](Elements/Markdown.md)

#### Flow Control Blocks / Misc

- [Conditionals](Conditional.md)
- [ForEach](ForEach.md) repetitions
- [AnyBlocks](AnyBlocks.md) type eraser
