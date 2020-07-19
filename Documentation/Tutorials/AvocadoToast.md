<h2>SwiftBlocksUI: 🥑🍞 Avocado Toast
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Work in Progress. Extract from 
[Instant “SwiftUI” Flavoured Slack Apps](https://www.alwaysrightinstitute.com/swiftblocksui/),
needs adjustments

TODO:
- Add app setup links
- Adjust content for standalone page
- Fix video

<hr>

The following is inspired by the "Avocado Toast App" used to demo SwiftUI in the
[SwiftUI Essentials](https://developer.apple.com/videos/play/wwdc2019/216)
talk. Didn't watch it yet? Maybe you should, it is about delicious toasts and
more.

We configured an `order-toast` global Shortcut
in the Slack [Admin Panel](https://api.slack.com/apps) above.
It already appears in the ⚡️ menu of the message compose field:

<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/client-shortcut-popup-markup.png" 
       style="border-radius: 5px; border: 1px solid #EAEAEA; width: 50%;">
</center>

#### API Access Token

The shortcut needs to interact with Slack using a client 
(we call out to Slack to open a modal, vs. just being called by Slack).
For this we need to go back to our app page in the 
<a href="https://api.slack.com/apps" target="Slack">Admin Panel</a>
and grab our "Bot User OAuth Access Token",
which can be found under the "OAuth & Permissions" section in the sidebar:

<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/slack-app-token.png" 
       style="border-radius: 5px; border: 1px solid #EAEAEA; width: 50%;">
</center>

Press "Copy" to get that token.
**Keep** that token **secure** and **do not commit** it to a git repository!<br>
Create a `.env` file right alongside your `main.swift`, and put your token in
there:
```
# Auth environment variables, do not commit!
SLACK_ACCESS_TOKEN=xoxb-1234567891234-1234567891234-kHHx12spiH1TZ9na3chhl2AA
```

Excellent.

#### Simple Order Form

A first version of our Avocado order form, 
I'd suggest to put it into an own `OrderForm.swift` file:
```swift
struct Order {
  var includeSalt            = false
  var includeRedPepperFlakes = false
  var quantity               = 1
}

struct OrderForm: Blocks {
  
  @Environment(\.user) private var user
  
  @State private var order = Order()
  
  var body: some Blocks {
    View("Order Avocado Toast") {
      Checkboxes("Extras") {
        Toggle("Include Salt 🧂",
               isOn: $order.includeSalt)
        Toggle("Include Red Pepper Flakes 🌶",
               isOn: $order.includeRedPepperFlakes)
      }
      TextField("Quantity",
                value: $order.quantity,
                formatter: NumberFormatter())
      
      Submit("Order") {
        console.log("User:", user, "did order:", order)
      }
    }
  }
}
```

This is what it looks like:
<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/client-order-form-1.png" 
       style="border-radius: 8px; border: 1px solid #EAEAEA; width: 50%;">
</center>

To trigger it when the ⚡️ shortcut is used, we need to hook it up as an
endpoint in the `body` of the app declaration:
```swift
Shortcut("order-toast") {
  OrderForm()
}
```

That's it, restart the app, try the shortcut. If the order is completed,
the app will log something like this in the terminal:
```
User: <@U012345ABC 'helge'> did order: 
  Order(includeSalt: false, includeRedPepperFlakes: true, 
  quantity: 12)
```

There are some things to discuss. First, the form declares an explicit
[`View`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Blocks/TopLevel/View.swift#L11).
This is only done here to give the modal a title 
("Order Avocado Toast").

Then there are two 
[`Checkboxes`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Blocks/Elements/Checkbox.swift#L14),
nothing special about those.
They use 
[`Bindings`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/GenericSwiftUI/Binding/Binding.swift#L9)
via the `$state` syntax to get and set values in our `Order` struct. 
Note how bindings can be chained to form a path.
```swift
Toggle("Include Salt 🧂",
       isOn: $order.includeSalt)
```

The "quantity" 
[TextField](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Blocks/Elements/TextField.swift#L13)
is special because it is using an `Int` value
alongside a (Foundation)
[Formatter](https://developer.apple.com/videos/play/wwdc2020/10160/):
```swift
TextField("Quantity",
          value: $order.quantity,
          formatter: NumberFormatter())
```
The formatter will make sure that the user entered an actual number.
If the user types some arbitrary content, it will emit a validation error
(shown by the client).

> App side validation can be done using Formatter's or by throwing the
> [InputValidationError](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/SwiftBlocksUI/EndpointActionResponse/InputValidationError.swift#L9)
> from within an action.

Again we use an Environment key, `user`, to get contextual information.
In this case, which users ordered the toast.

#### Intermission: Lifecycle Phases

There are three request processing phases when dealing with requests sent
by Slack:
1. takeValues: 
   If the request arrives, SwiftBlocksUI first pushes all values into the Blocks.
2. invokeAction:
   Next it invokes an action, if there is one.
3. render:
   And finally it returns or emits some kind of response, e.g. by rendering the
   blocks into a new message or modal view, or returning validation errors.

> Slack has various styles on how to return responses, 
> including things called 
> `Response Types`, `Response URLs`, `Trigger IDs`, or WebAPI client.
> SwiftWebUI consolidates all those styles in a single API.

[`@State`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Hosting/State.swift#L9)
must be used if values need to survive between those phases, as the Blocks
will get recreated for each of them.
In SwiftBlocksUI `@State` does **not** persist for longer than a single 
request/response phase!
To keep state alive, one can use various mechanisms, including
[MetaData keys](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Hosting/MetaData.swift#L14).

#### Add Ordering Options

Just Salt'n'Pepper, really? We need more options! 
This is Swift, so we encode the options in proper enums, 
I'd put them in a separate file `ToastTypes.swift`:
```swift
enum AvocadoStyle {
  case sliced, mashed
}

enum BreadType: CaseIterable, Hashable, Identifiable {
  case wheat, white, rhy
  
  var name: String { return "\(self)".capitalized }
}

enum Spread: CaseIterable, Hashable, Identifiable {
  case none, almondButter, peanutButter, honey
  case almou, tapenade, hummus, mayonnaise
  case kyopolou, adjvar, pindjur
  case vegemite, chutney, cannedCheese, feroce
  case kartoffelkase, tartarSauce

  var name: String {
    return "\(self)".map { $0.isUppercase ? " \($0)" : "\($0)" }
           .joined().capitalized
  }
}
```

Add the new options to the `Order` structs:
```swift
struct Order {
  var includeSalt            = false
  var includeRedPepperFlakes = false
  var quantity               = 1

  var avocadoStyle           = AvocadoStyle.sliced
  var spread                 = Spread.none
  var breadType              = BreadType.wheat
}
```

And the updated `OrderForm`:
```swift
struct OrderForm: Blocks {
  
  @Environment(\.user) private var user
  
  @State private var order = Order()
  
  var body: some Blocks {
    View("Order Avocado Toast") {
      
      Picker("Bread", selection: $order.breadType) {
        ForEach(BreadType.allCases) { breadType in
          Text(breadType.name).tag(breadType)
        }
      }
      
      Picker("Avocado", selection: $order.avocadoStyle) {
        "Sliced".tag(AvocadoStyle.sliced)
        "Mashed".tag(AvocadoStyle.mashed)
      }
      
      Picker("Spread", Spread.allCases, selection: $order.spread) { spread in
        spread.name
      }
      
      ...
    }
  }
}
```
This demonstrates various styles of 
[Pickers](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/Blocks/Blocks/Elements/Picker/Picker.swift#L11).
The first one uses an explicit `ForEach` to iterate over the bread types
(and add the options)
the second one uses a static set of options (the `tag` being used to identify
them),
and the last one iterates over an array of
[Identifiable](https://nshipster.com/identifiable/)
values.

This is what we end up with. On submission the Submit action has a properly
filled, statically typed, `Order` object available:

<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/client-order-form-2.png" 
       style="border-radius: 8px; border: 1px solid #EAEAEA; width: 50%;">
</center>

As a final step, let's send the user an order confirmation message.
Notice the embedded Blocks struct to build field pairs in a consistent
manner, this is a power of SwiftUI - easy composition:
```swift
struct OrderConfirmation: Blocks {
  
  let user  : String
  let order : Order
  
  struct TitledField<C: Blocks>: Blocks {
    let title : String
    let content : C
    
    init(_ title: String, @BlocksBuilder content: () -> C) {
      self.title   = title
      self.content = content()
    }
    
    var body: some Blocks {
      Group {
        Field { Text("\(title):").bold() }
        Field { content }
      }
    }
  }
  
  private let logo =
    Image("ZeeYou",
          url: URL(string: "https://zeezide.com/img/zz2-256x256.png")!)
  
  var body: some Blocks {
    Section {
      Accessory { logo }
      
      "\(user), thanks for your 🥑🍞 order!"
      
      Group {
        TitledField("Quantity") { "\(order.quantity)"     }
        TitledField("Bread")    { order.breadType.name    }
        TitledField("Style")    { order.avocadoStyle.name }
      
        if order.spread != .none {
          TitledField("Spread") { order.spread.name }
        }

        if order.includeRedPepperFlakes || order.includeSalt {
          TitledField("Extras") {
            if order.includeRedPepperFlakes { "🌶" }
            if order.includeSalt            { "🧂" }
          }
        }
      }
    }
  }
}
```

It is sent to the user as a DM by the `OrderForm` in the `submit` action:
```swift
let confirmationMessage =
  OrderConfirmation(user: user.username, order: order)

client.chat.sendMessage(confirmationMessage, to: user.id) { error in
  error.flatMap { console.error("order confirmation failed!", $0) }
}
```

<center>
  <video autoplay="autoplay" controls="controls"
         style="border-radius: 5px; border: 1px solid #EAEAEA; width: 80%;">
    <source src="https://zeezide.de/videos/blocksui/blocksui-AvocadoToastOrder-demo.mov" type="video/mp4" />
    Your browser does not support the video tag.
  </video>
</center>



We'll stop here for the demo, but imagine Avocado Toast as a complete
avocado toast ordering solution.
The whole order flow would live inside Slack:
- There would need to be an order database, with the order keyed by user.
- The order database could keep a reference to the order confirmation message.
- When an order is submitted, the shortcut could also create an interactive
  message in a `#toast-orders` channel. 
  That message could have a "Take order" button which a fulfillment agent could 
  press to take responsibility. 
  If pressed, both this message and the original order confirmation message 
  could be updated ("Adam is doing your order!")
  - It could also start a timer to auto-cancel the order if no one takes it.
- All messages could have a "cancel" button to stop the process.
- Finally the Home Tab of the app could show the history of orders for the
  respective user (either as a customer or agent).

Would be nice to complete the sample application on GitHub to implement the
whole flow.
