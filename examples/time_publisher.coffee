#!/usr/bin/env coffee

client = require('../src/simple_pubsub_client').connect()
publish_time = () -> client.publish new Date(), 'current-time'
timer_id = setInterval publish_time, 1000
client.on 'io-error', (err) -> clearInterval timer_id

