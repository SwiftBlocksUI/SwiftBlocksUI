<h2>SwiftBlocksUI: FAQ
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

### Q: How do I add raw Slack Markdown?

Use the [Markdown](Blocks/Elements/Markdown.md) element to add arbitrary,
raw Slack markdown.

```swift
Section {
  Markdown("*Important* Text by <@U7272626>!")
}
```

### Q: How can I create a website link?

Using the [Link](Blocks/Elements/Link.md) element, for example:

```swift
Section {
  Link("ZeeZide", destination: URL(string: "https://zeezide.de/")!)
}
```

### Q: How can I mention/link users in blocks?

Use the [Markdown](Blocks/Elements/Markdown.md) element, the
syntax for user references is: `<@USERID>` or `<@USERID|TheName>`.

```swift
Section {
  Markdown("Text by <@U7272626>!")
}
```

### Q: How can I embed Links in a text section?

Example:

```swift
Section {
  Text("This site is nice: ")
  Link("ZeeZide", destination: URL(string: "https://zeezide.de")!)
}
```

### Q: How do I put images into the upper right of a section?

The "upper right" position is a so called "Accessory", available using the 
[Accessory](Blocks/Elements/Accessory.md) element.
Only a single element can be placed into the accessory.

One can place various things into the accessory,
including [Image](Blocks/Elements/Image.md) elements.
Various interactive elements like [DatePicker](Blocks/Elements/DatePicker.md)
also work!

```swift
Section {
  Accessory {
    Image("ZeeYou", 
      url: URL(string: "https://zeezide.com/img/zz2-256x256.png")!)
  }
  
  Text("A section w/ an accessory.")
}
```

### Q: How do I sent a Blocks based direct message to a user?

```swift
let message = MyBlocksBasedMessage()
client.chat.sendMessage(message, to: UserID("@727272")) { error in
  console.error("Ups, could not send the message to the user:", error)
}
```
