#  SlackBlocksModel

This contains a, slightly overengineered, Swift representation of the Slack 
JSON API.

Arguably, many things should be classes, nor structs and enums :-) But this way 
it pleases the Swift user's Safyness.

It also makes the `Block` enum ridiculously large (~210 bytes) 🤓
Fix is to make the associated values proper 🐮 structs. But hey, why can't Swift
generate that code for me?!
