<h2>SwiftBlocksUI: Block Elements
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Work in Progress.

<hr>

Elements are `Blocks` nested inside the top-level Slack blocks (a message is a list
of top-level blocks).

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

#### Element Blocks

Element blocks can be used at the top-level, they'll auto-wrap themselves in a default
Top-Level block.

- [Text](Text.md)
- [Link](Link.md)
- [Image](Image.md)
- Interactive Elements
  - [Button](Section.md)
  - [TextField](TextField.md)
  - [CheckboxGroup](CheckboxGroup.md)
    - [Checkbox](Checkbox.md)
  - [Picker](Picker.md)
    - [Option](Option.md)
  - [DatePicker](DatePicker.md)
- Section Elements
  - [Accessory](Accessory.md)
  - [Field](Field.md)
- Rich Text Styling
  - [Paragraph](Paragraph.md), regular content
  - [Preformatted](Preformatted.md), triple-backtick markdown style code sections
  - [Quote](Quote.md), `>` indented quote content
- [Markdown](Markdown.md)
