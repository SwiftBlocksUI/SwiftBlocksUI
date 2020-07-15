# BlocksExpress

[MacroExpress](https://github.com/Macro-swift/MacroExpress) 
enhancements to process [Blocks](../Blocks/README.md) requests and responses.

This contains some middleware and enhancements to `IncomingRequest` and
`ServerResponse`.


## IncomingRequest

TODO: document

New Properties:
- `interactiveRequest` (filled by the respective middleware below)

## ServerResponse

TODO: document

## Middleware

### `sslCheck`

Once an app is deployed, Slack periodically sends "server side live" checks to
the endpoint. This middleware deals with them and should be inserted at the
top of the middleware stack.

The middleware can also verify the (old & deprecated) verification token of 
a Slack application (you'll find it in the "Basic Information" section of
your app).

Example usage:

    app.use(logger("dev"), bodyParser.urlencoded(),
            sslCheck(verifyToken(allowUnsetInDebug: true)))

This will grab the verification token from the `SLACK_VERIFICATION_TOKEN`
environment variable if the app is compiled in release mode,
but skip the check in debug mode.

The `verifyToken` handler is provided as part of the middleware.

### Slash Command endpoint: `slash`

This middleware hooks up a processing closure for a Slack slash command
(like `/vaca`).
If the request is a matching Slash request, it parses all the data and invokes
the handler. The handler *must* end the response (send content or a status).

Note: A Slack slash command endpoint has 3 seconds to respond, otherwise
      Slack will show an error.

Example:

    app.slash("vaca") { req, res in
      res.sendMessage(scope: .userOnly) {
        "Hello World!"
      }
    }
    
### `bodyParser.interactiveRequest`

Parses a `SlackBlocksModel.InteractiveRequest` from incoming POST values
and puts it into the `IncomingMessage` (`interactiveRequest` property).

Example:

    app.post(bodyParser.interactiveRequest())
    app.post { req, res, next in
      console.log("interactive request:", req.interactiveRequest)
    }

### `bodyParser.parseBlocksEnvironment`

This extracts commonly used variables in a request independent way, i.e. it 
works for Slash requests and the various interactive requests. The values are 
put into a `BlocksEnvironment` struct which is accessible using the 
`blocksEnvironment` property of the `IncomingMessage`.

Properties (all optional, availability depends on the request):
- `user`
- `team`
- `conversation`


Example:

    app.post(bodyParser.parseBlocksEnvironment())
    app.post { req, res, next in
      console.log("A user interacted w/ our app:", req.blocksEnvironment.user)
    }

### Interactive Endpoints: `messageAction`, ...

TODO: document middleware:

- `interactiveRequest`
  - fills `IncomingMessage.interactiveRequest`
  - used as basis for more specific version:
    - `viewSubmission`
    - `messageAction`
    - `shortcut`
