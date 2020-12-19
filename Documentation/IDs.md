<h2>SwiftBlocksUI: IDs
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

And important thing in Block Kit and Slack, and hence SwiftBlocksUI 
are the various kinds of "IDs" involved. And how those can be set in
SwiftBlocksUI.

There are other IDs in Slack (like channel ids, user ids, file ids, etc), this is
only about the IDs used to drive interactive forms and messages.

The key IDs here are:
- Callback IDs
- Block IDs
- Action IDs

Callback IDs are the IDs set in the Slack admin interface for shortcuts. They
tell the server which of the apps shortcuts got invoked.
In SwiftBlocksUI we also use the term "Callback ID" for IDs used to route
requests which do not have explicit "callback IDs" in the app configuration.
More on that later.

Block IDs are very similar to HTML element IDs. Remember that unlike in HTML
Block Kit blocks do not nest, each message or form is a 1-level array of blocks.

Action IDs are similar to the "name"s of HTML form elements. When an interactive
element is pressed, it generates a block action containing that name.
Interactive elements also have a "value", again similar to HTML form elements.


### Automatic Block ID Generation

Let's take a look at the blocks used in the [ClipIt](Tutorials/ClipIt.md) example:
```swift
var body: some Blocks {
  View("Save it to ClipIt!") {
    TextEditor("Message Text", text: $messageText)
    
    Picker("Importance", selection: $importance,
           placeholder: "Select importance")
    {
      "High 💎💎✨".tag("high")
      "Medium 💎"  .tag("medium")
      "Low ⚪️"     .tag("low")
    }
    
    Submit("CliptIt", action: clipIt)
  }
}
```

This doesn't actually contain any explicit blocks, the blocks get added 
automagically.
This is the same with explicit [Input](Blocks/TopLevel/Input.md) blocks:

```swift
var body: some Blocks {
  View("Save it to ClipIt!") {
    Input { // a block
      TextEditor("Message Text", text: $messageText)
    }
    
    Input { // a block
      Picker("Importance", selection: $importance,
             placeholder: "Select importance")
      {
        "High 💎💎✨".tag("high")
        "Medium 💎"  .tag("medium")
        "Low ⚪️"     .tag("low")
      }
    }
    
    Submit("CliptIt", action: clipIt) // submit is special
  }
}
```

There are two [Input](Blocks/TopLevel/Input.md) blocks containing an element each.
At the API level it will look like this:

```json
blocks: [
  {
    "type": "input",
    "block_id" : "ABC251.0",
    "element": {
      "type"      : "plain_text_input",
      "action_id" : "ABC251.0.0"
    },
    "label": {
      "type"  : "plain_text",
      "text"  : "Message Text",
      "emoji" : true
    }
  },
  {
    "type": "input",
    "block_id" : "ABC251.1",
    "element": {
      "type"        : "static_select",
      "action_id"   : "ABC251.1.0",
      "placeholder" : { "type": "plain_text", "text": "Select importance" },
      "options"     : [
        { "text": { "type": "plain_text", "text": "High 💎💎✨" },
          "value": "high"
        },
        { "text": { "type": "plain_text", "text": "Medium 💎" },
          "value": "medium"
        },
        { "text": { "type": "plain_text", "text": "Low ⚪️" },
          "value": "low"
        }
      ]
    },
    "label": {
      "type"  : "plain_text",
      "text"  : "Importance",
      "emoji" : true
    }
  },
]
```

Those are the IDs SlackBlocksUI automagically generates:
- `ABC251` (what we call the "Callback ID")
- `ABC251.0` (block ID)
- `ABC251.1` (block ID)
- `ABC251.0.0` (action ID)
- `ABC251.1.0` (action ID)

`ABC251` is what we call the `root element ID` - or "Callback ID". 
It allows SlackBlocksUI to backmap requests to the user defined
Blocks structure (the `struct ClipItForm: Blocks {}` in the example).
If no explicit ID is given, the ID is generated based on the static Swift type of the Blocks.
It is some base64 encoded data and will look like a sequence of digits and letters.

As mentioned Block Kit blocks are a 1-level array. Since we don't nest them in
a conditional (`if`) or a `ForEach`, our tree will actuall be flat. 
So the auto-assigned "relative" IDs for the blocks will be "0" (first Input) and 
"1" (second Input).
They get prefixed with the root-ID and up in `ABC251.0` and `ABC251.1`.

> If `ForEach` or `if` are used, more information is embedded in that "element ID".

Finally, the contained [TextField](Blocks/Elements/TextField.md)
and [Picker](Blocks/Elements/Picker.md)
get "action-ids" assigned by the same approach. As the elements are rendered, they
get increasing IDs assigned. In this case the relative ID of both is `0` because they
are the sole element within the respective [Input](Blocks/TopLevel/Input.md) block.


### Request Handling

In the Clipit example three things can happen:

1. the view is submitted,
   a "view submission" interactive request will be send to our app server (modal gets closed)
2. the value of the static select is changed,
   a "blocks action" interactive request will be send to our app server (modal stays open)
3. the view is closed,
   a "view closed" interactive request will be send to our app server (modal gets closed)

When a view is submitted, the HTTP request carries two things:
- the view description, which is essentially the whole API JSON describing the view
- the state dictionary

The state dictionary will contain the states of all the elements with "action IDs",
in this case it'll look like (simplified):
```
[ "ABC251.0.0": "Hello World",
  "ABC251.1.0": "high" ]
```

The view description will have the blocks, like:
```
blocks: [
  { "type": "input",
    "block_id" : "ABC251.0",
    ...
]
```

When the request arrives SwiftBlocksUI first looks for a root-ID `ABC251`.
This is what it internally also calls a "Callback ID", because it allows us
to route the request back to the right user provided Blocks
(the `struct ClipItForm: Blocks {}` in the example).

Once it located the Blocks structure, SwiftBlocksUI will essentially repeat
the rendering process (simplified) two times:

1. the takeValues phase, where the state is pushed back into the View
2. the invokeAction phase, when an action closure is called

Those are two distinct phases, because all the form values must be back in
the View before the action can run (otherwise it might see a partially filled
structure).

Because the structure is walked the same way like during rendering,
the same IDs will get generated.
```swift
struct ClipItForm: Blocks {

  @State var messageText
  var body: {
    TextEditor("Message Text", text: $messageText)
  }
}
```

When the [TextEditor](Blocks/Elements/TextField.md) is processed,
it knows its current element ID (`ABC251.0.0`) and will look into the
state dictionary for a new value:
```
[ "ABC251.0.0": "Hello World",
  "ABC251.1.0": "high" ]
```
Et voilà: `Hello World`. It will then push the new value into the `$messageText` binding
(call the setter).

#### Summary

- Blocks Callback IDs can be autogenerated by the framework. They are used
  to find the block which triggered an action.
  Those are registered if a block is rendered and are based on the static type of
  the block.
  They are also called "root element IDs" internally.
- Block IDs can be autogenerated by the framework. They depend on the position in
  the blocks hierarchy.
- Action IDs can be autogenerated by the framework, works the same way like
  block IDs.


### Explicit IDs

Automatic IDs are great to get started quickly.
But for production apps it is better to use stable, explicit IDs.
Why? Because as you reposition elements in a Blocks struct, their IDs can change.

What still can be (and should be) used is the relative structure of IDs:

    ROOT-ID.BLOCK-ID.ACTION-ID

#### Explicit Block IDs

Block IDs come in 4 styles (see the `BlockIDStyle` struct):
- `.globalID(BlockID)` (typed string)
- `.rootRelativeID(String)`
- `.elementID` (the generated position based ID, e.g. `0.1.2.3`)
- `.auto` (will usually pick `elementID`)

`.auto`/`.elementID` is the default, the auto generation of IDs.

Any style can be chosen when passing it in using the `id` parameter of the Blocks
`init`:
```swift
var body: some Blocks {
  Input(id: .globalID("text") {
    TextEditor("Message Text", text: $messageText) 
  }
}
```

This will end up like this: `text.ACTION-ID`. Note that the "ROOT-ID" is not available,
SwiftBlocksUI itself can't extract a "Callback ID anymore".
When using global IDs, the backmapping has to be done by the user (by manually
matching the ID in the middleware).

The recommended way is to use a root relative ID.
It can be set using the `.id` modifier:
```swift
  Input {
    TextEditor("Message Text", text: $messageText)
  }
  .id("message")
}
```
This will end up like this: `ROOT-ID.message.ACTION-ID`. So this will be stable,
even if the block is moved up or down.
The ROOT-ID (Callback ID) is still availabel and SwiftBlocksUI can do some lookup work.

#### Explicit Action IDs

This works similar to block IDs, but there is an additional `actionID` modifier:

```swift
var body: some Blocks {
  Input {
    TextEditor("Message Text", text: $messageText) 
      .id("title")
  }
  .id("message")
}
```
This will end up like this: `ROOT-ID.message.title`. Stable.

A real global ID can be set using the `actionID`:
```
var body: some Blocks {
  Input {
    TextEditor("Message Text", text: $messageText) 
      .actionID(.globalID("de.zeezide.blocks.msg.title"))
  }
  .id("message")
}
```
This will end up like this: `de.zeezide.blocks.msg.title`.
It isn't recommended, but this is actually possible w/o the Blocks lookup
getting confused (it will extract the Callback ID from the block ID containing
the actionable element).

It can make sense when moving actionable elements to different block is
an expected thing.


#### Explicit Callback IDs

This is a little more tricky and non-obvious. The naive approach would look like this:

```swift
struct ClipItForm: Blocks {

  @State var messageText
  
  var body: {
    View {
      Input {
        TextEditor("Message Text", text: $messageText)
          .id("text")
      }
      .id("message")
    }
    .id("clip-it-form")
  }
}
```

With the expectation that this is the result: `clip-it-form.message.text`.
Unfortunatly that doesn't work as expected (at least not yet).

The reason is, that when the block gets send:
```swift
MessageAction("clipit") {
  ClipItForm()
}
```
... the outer/top-level Blocks is still `CliptItForm`, not the `id` modified embedded 
in the `body`.

The solution is doing this:
```swift
MessageAction("clipit") {
  ClipItForm()
    .id("clip-it-form")
}
```

Now the `id` modifier is top-level and can provide the `id` to the rendered/request
handler.

This can get a little annoying if the same top-level Blocks struct is used in multiple
places. It always needs to be wrapped in `id` modifiers to route actions back to the origin.
E.g.:
```swift
MessageAction("clipit") {
  ClipItForm()
    .id("clip-it-form")
}
Shortcut("clipit") {
  ClipItForm()
    .id("clip-it-form")
}
```

The solution to this is to mark the `ClipItForm` as a `CallbackBlock`
and provide the default Callback ID:

```swift
struct ClipItForm: Blocks, CallbackBlock {
  
  var callbackBlockID : CallbackID? { "clip-it-form" )

  @State var messageText
  
  var body: {
    View {
      Input {
        TextEditor("Message Text", text: $messageText)
          .id("text")
      }
      .id("message")
    }
    .id("clip-it-form")
  }
}
```

Note: A user of this can still override the `id` by wrapping the blocks as shown above!

A final quirk is the back mapping of requests. Which endpoint does this?
Actually both `MessageAction` and `Shortcut` can do this.
They do not only handle the shortcut invocation requests, but also all the
actions which can occur for `ClipItForm` (i.e. view submission/close and block
actions).

Sometimes Blocks are generated by other means, e.g. periodically or after some
processing. In those cases they need to be registered explicitly for back mapping,
currently using the `interactiveBlocks` middleware, e.g:

```swift
Use(interactiveBlocks { ClipItForm() })
```

This middleware handles just view submission etc to `clip-it-form`.
