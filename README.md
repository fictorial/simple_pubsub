# A Simple PUBSUB Server and Client for Node.js

A publisher publishes a message on a channel which is just a string name.
A subscriber subscribed to the channel will be forwarded the published message.

This server is meant for internal/backend use only.  Publishers and
subscribers talk to a PUBSUB server over TCP/IP.

The NPM package is JavaScript compiled from CoffeeScript. Use the git
repository to work with the CoffeeScript version.

## Installation

    npm install simple_pubsub

## Running a PUBSUB Server

    simple_pubsub_server [OPTIONS]

    --listen <ip:port>      Default: 127.0.0.1:9912
    --loglevel <level>      Default: error

## Example Publisher

    var client = require('simple_pubsub').connect();
    var timer_id = setInterval(function () {
      client.publish(new Date(), 'current-time');
    }, 1000);
    client.on('io-error', function (err) {
      clearInterval(timer_id);
    });

## Example Subscriber

    require('simple_pubsub').connect().subscribe('current-time', function (msg, chan) {
      console.log("The time is " + msg);
    });

## API

### module: simple_pubsub

#### function: connect(port=9912, host='127.0.0.1')

Returns a **SimplePubsubClient** object.

### object: SimplePubsubClient

#### event: io-error (err)

An input/output error occurred.

#### event: protocol-error (err)

Someone wrote a malformed message.

#### event: message (msg, chan)

All messages that are received due to some subscription.

#### method: subscribe(chan, cb)

Subscribe to a channel 'chan' and call back function 'cb' with the `msg`
and `chan` when a message is published to 'chan'.

#### method: publish(msg, chan)

Publish a message 'msg' to channel 'chan'.

## Notes

System messages are published on a reserved channel named `simplepubsub`.
All clients are implicitly subscribed to this channel.

## Limitations

Wildcard channel names are unsupported; publishers and subscribers must
use literal channel names, not patterns.

Offline storage is unsupported.

## Protocol

All messages are encoded as CRLF delimited JSON objects.

### Subscribe

A client subscribes to a channel.

    { sub: 'channel' }

### Publish

A client publishes a message to one or more channels.
The same message is forwarded to subscribers.

    { pub: { msg: value, chan: 'channel' } }

## Author

Brian Hammond <brian@fictorial.com> (http://fictorial.com)

## License

MIT
