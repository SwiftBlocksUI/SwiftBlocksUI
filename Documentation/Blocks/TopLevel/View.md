<h2>`View` Blocks
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

A View for "Modals" or the application's "HomeTab".

A View is a set of blocks plus some meta data. They can contain regular
block actions, or Input elements w/ Buttons, which are then transferred
over to the server in "view submissions" (pretty much a form submit).

They are exposed as a `Blocks` element, but one can only every render a
single View (but one can switch between views using if/else etc).

Example:

```swift
View {
  TextField("Message Text", text: $messageText, multiline: true)
  
  Picker("Importance", selection: $importance) {
    "High 💎💎✨".tag("high")
    "Medium 💎"  .tag("medium")
    "Low ⚪️"     .tag("low")
  }
  
  Submit("CliptIt") {
    print("Clipping:", messageText, importance)
  }
}
```

### Modals

Note: Modal "Views" have nothing to do with SwiftUI views. They are more
      like UIViewController's contained within a UINavigationViewController
      (they stack upon each other and keep their state).

While a modal can have multiple (up to 3) views active (stacked), there is
only ever a single `View` in an API call (and open to the user).
Views can be "opened", "pushed" and "updated". All those require that a
"trigger ID" is available.

Modals do NOT appear in the API structures, they have no ID which is
transmitted to the server. It is always the "Views" one acts upon.

Views are either opened using the client API, or can be returned in a
response action (which also can be an update w/ errors).

Docs:
- https://api.slack.com/surfaces/modals
- https://api.slack.com/surfaces/modals/using#pushing_views
- https://api.slack.com/methods/views.open (this is really a modal.open)

### Application Home Tabs

An application home has multiple tabs, and the "Home Tab" can be customized
by the app using a _single_ View, which can contain up to 100 blocks.

Home Tabs are bound to a user and need to be pushed using views.publish,
i.e. they do not exist automatically.

Depending on the view type, the application may need to track which users
require tab updates in a database.

Note: Home tabs need to be enabled in the Admin UI for your application.

Deep link to home tab: `slack://app?team=TEAMID&id=APPID&tab=home`

Docs: https://api.slack.com/surfaces/tabs/using
