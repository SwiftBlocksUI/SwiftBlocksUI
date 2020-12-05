# SlackClient

A tinsy client for Slack. 
This is only intended to implement the pieces necessary for SwiftBlocksUI,
not as a general purpose package.

The required token (`xoxp-xyz...`) can either be provided using the
`token` parameter, or the `SLACK_ACCESS_TOKEN` variable can be set
in the environment.

Logging out outgoing requests can be enabled by setting the
`LOG_SLACK_CLIENT_POSTS` environment variables to `yes` (or `да`).


### SwiftBlocksUI

Note: The `SwiftBlocksUI` module contains some extensions to this basic client.

Example:

```swift
let client = SlackClient() // use SLACK_ACCESS_TOKEN env var

client.views.open(MyView(), with: action.triggerID) { error, json in
   ...
}
```
