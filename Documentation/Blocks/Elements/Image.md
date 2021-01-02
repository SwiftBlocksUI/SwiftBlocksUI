<h2>`Image` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Show a remote image.

This can be a top level block element (aligned vertically within the content),
or an element within a [`Context`](../TopLevel/Context.md) block,
or [`Section`](../TopLevel/Section.md) [accessory](Accessory.md).

Example:

```swift
Image("A cute kitten",
      url: URL("http://placekitten.com/500/500")!)

```

Two `Image`s in a [`Contexts`](../TopLevel/`Contexts`.md) block:
![block types](https://zeezide.de/img/blocksui/BlockTypes-Annotated.png)

Docs: https://api.slack.com/reference/block-kit/block-elements#image


### Blocks API Representation

When used as a block:

```json
{
  "type"      : "image",
  "image_url" : "http://placekitten.com/500/500",
  "alt_text"  : "A cute kitten",
  "title"     : {
    "type"  : "plain_text",
    "text"  : "A cute kitten",
    "emoji" : true
  }
}
```
