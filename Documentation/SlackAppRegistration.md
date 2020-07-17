<h2>SwiftBlocksUI: Slack App Registration
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

Work in Progress. Extract from 
[Instant “SwiftUI” Flavoured Slack Apps](https://www.alwaysrightinstitute.com/swiftblocksui/),
needs adjustments.

TODO:
- Add app setup links
- Adjust content for standalone page
- Fix video

<hr>
## Development Environment Setup

The environment setup looks like much, 
but it can actually be done in about 10 minutes.
It involves: 
Creating a workspace, 
registering a Slack app,
getting public Internet access,
configuring the Slack app to point to it.<br>
It is a one-time thing, a single app registration can be used to test out
multiple Shortcuts, Slash commands etc.

If you just want to see the code, directly jump to:
[Cows](#cows)
and
[AvocadoToast](#-avocado-toast).

### Create Development Workspace & Register App

Unfortunately there is no way to build Slack apps using just local software,
a real Slack workspace is required.
Fortunately it is super easy to create an own Slack workspace for development
purposes, follow:
<a href="https://slack.com/create" target="Slack">Slack Create Workspace</a>.

Just four steps (takes less than 5 minutes):
1. Enter your email
2. Slack sends a 6 digit code, enter that
3. Enter a unique name for your workspace (like "SBUI-Rules-27361")
4. Enter an initial channel name (like "Block Kit")

Now that we have that, we need to register our application,
again super easy, just click:
<a href="https://api.slack.com/apps?new_app=1" target="Slack">Create New App</a>,
then enter an app name and choose the development workspace just created.

<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/slack-createapp.png" 
       style="border-radius: 8px; border: 1px solid #EAEAEA; width: 50%;">
</center>

Congratulations, you've registered your first Slack app!
Slack will show you a bigger web page with lots of buttons and options.
You can always find the way back to your apps by going to:
<a href="https://api.slack.com/apps" target="Slack">https://api.slack.com/apps</a>.

### Giving Slack access to your development machine

Remember that Slack "apps" are just HTTP endpoints, i.e. web apps.
The next hurdle is finding a way to let Slack connect to your local
development machine, which very likely isn't reachable on the public
Internet.<br>
There are various options, we'll look at two: 
[SSH port forwarding](https://help.ubuntu.com/community/SSH/OpenSSH/PortForwarding)
and 
[ngrok](https://ngrok.com).

**Important**: Forwarding makes a port available to the public Internet.
Only keep the tunnel up while you are developing.

#### ngrok

[Ngrok](https://ngrok.com) is a service which provides port forwarding.
It can be used for free, with the inconvenience that new URLs will be generated
each time it is restarted.
Slack also has nice documentation on how to do
[Tunneling with Ngrok](https://api.slack.com/tutorials/tunneling-with-ngrok).

Short version:
```swift
brew cask install ngrok # install
ngrok http 1337         # start
```
This is going to report an NGrok URL like `http://c7f6b0f73622.ngrok.io` that
can be used as the Slack endpoint.

#### SSH Port Forwarding

If SSH access to some host on the public Internet is available
(e.g. a $3 Scaleway development instance is perfectly fine),
one can simply forward a port from that to your local host:

```bash
ssh -R "*:1337:localhost:1337" YOUR-PUBLIC-HOSTNAME
```

Choose any free port you want, this sample is using `1337`.

> The `GatewayPorts clientspecified` line may need to be added to the host's
> `/etc/ssh/sshd_config` to get it to work.

### Configure Application Endpoints

Now that a public entry point is available using either SSH or Ngrok,
it needs to be configured in the Slack app.
If you closed the web page in the meantime,
you'll find your app by going to this URL:
<a href="https://api.slack.com/apps" target="Slack">https://api.slack.com/apps</a>.

> If you are using the free version of ngrok, you'll have to update the
> endpoints every time you restart the `ngrok` tool.

Slack can be configured to invoke different URLs for different things,
e.g. a Slash command can be hosted on one server and interactive messages
on a different one.<br>
With SwiftBlocksUI you can use the same URL for all endpoints, it'll figure out
what is being requested and do the right thing.

Lets configure two things:
1. Shortcuts
2. Slash Commands

#### Shortcuts

Go to the "Basic Information" section on your app's Slack page,
and select "Interactive Components". Turn them on.
You need to configure a `Request URL`. Enter your public entry point URL,
for example: `http://c7f6b0f73622.ngrok.io/avocadotoast/`:

<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/slack-app-interactivity.png" 
       style="border-radius: 8px; border: 1px solid #EAEAEA; width: 50%;">
</center>

Next click on "Create New Shortcut", choose "global shortcut".
Global Shortcuts appear in the ⚡️ menu of the message compose field:

<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/slack-app-global-shortcut.png" 
       style="border-radius: 8px; border: 1px solid #EAEAEA; width: 50%;">
</center>

The important thing is to create a **unique Callback ID**, `order-toast` in
this case.
It'll be used to identify the 
[`Shortcut`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/SwiftBlocksUI/Endpoints/Shortcut.swift#L17)
on the SwiftBlocksUI side:
```swift
Shortcut("order-toast") { // <== the Callback ID
  OrderPage()
}
```

Let's also create a Message Action while we are here. 
Again click "Create New Shortcut", but this time choose "On messages".

<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/slack-app-message-shortcut.png" 
       style="border-radius: 8px; border: 1px solid #EAEAEA; width: 50%;">
</center>

Again, make sure the Callback ID is unique: `clipit` in this case.
It'll pair with the 
[`MessageAction`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/SwiftBlocksUI/Endpoints/MessageAction.swift#L17) 
endpoint:
```swift
MessageAction("clipit") {
  ClipItView()
}
```
on our application side.

The "Select Menus" section can be ignored, they are used for popups with 
auto-completion driven by an app.
Dont' forget to press "**Save Changes**" on the bottom.

#### Slash commands

To play with the cows, lets also configure a Slash command.
Click "Slash Commands" in the sidebar of your Slack app page, then
"Create New Command":

<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/slack-app-slash-command.png" 
       style="border-radius: 8px; border: 1px solid #EAEAEA; width: 50%;">
</center>

Enter the same URL as in the "Interactive Components" setup. 
Press "Save" to create the command.

Slash commands will be processed in the
[`Slash`](https://github.com/SwiftBlocksUI/SwiftBlocksUI/blob/develop/Sources/SwiftBlocksUI/Endpoints/Slash.swift#L43)
endpoint:
```swift
Slash("vaca", scope: .userOnly) {
  Cow()
}
```

#### Other configuration

That's all the configuration we need for now.
On the same app page additional permissions are configured for the app,
for example whether the app can send messages to channels,
or create channels, and so on.
It is also the place where "Incoming Webhooks" are configured,
this is where Slack would call into our app when certain events happen.
We don't need this either.

#### Install the App

The final step is to install the app in the development workspace.
Go to the "Basic Information" section of your app's Slack page,
and choose the big "Install your app to your workspace":

<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/slack-app-install.png" 
       style="border-radius: 5px; border: 1px solid #EAEAEA; width: 50%;">
</center>

Once finished, the Slack client will show the app in the "Apps" section:

<center>
  <img src="https://www.alwaysrightinstitute.com/images/blocksui/client-app-hometab.png" 
       style="border-radius: 5px; border: 1px solid #EAEAEA; width: 50%;">
</center>

Success, finally **SwiftBlocksUI coding can start**!
