<h2>SwiftBlocksUI: Technology Overview
  <img src="https://zeezide.com/img/blocksui/SwiftBlocksUIIcon256.png"
       align="right" width="100" height="100" />
</h2>

[Instant “SwiftUI” Flavoured Slack Apps](https://www.alwaysrightinstitute.com/swiftblocksui/),

Slack "apps" are just HTTP endpoints, i.e. web apps.
The next hurdle is finding a way to let Slack connect to your local
development machine, which very likely isn't reachable on the public
Internet.

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
