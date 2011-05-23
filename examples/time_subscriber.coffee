#!/usr/bin/env coffee

client = require('../src/simple_pubsub_client').connect()
client.subscribe 'current-time', (msg, chan) -> console.log "The time is #{msg}"

