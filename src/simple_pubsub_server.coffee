#!/usr/bin/env coffee

net = require 'net'
argv = require('optimist').default(listen:'127.0.0.1:9912', loglevel:'error').argv
Log = require 'log'
log = new Log argv.loglevel

CRLF = '\r\n'

next_client_id = 0
clients = {}   # client.id => socket
all_subs = {}  # chan => { client_id = > true }

server = net.createServer (client) ->
  client.setTimeout 0
  client.setKeepAlive true
  client.setEncoding 'utf8'

  client.id = next_client_id++
  clients[client.id] = client
  client.subs = {}  # chan = > true

  client.on 'data', (data) =>
    try
      for line in data.split '\r\n'
        continue unless line.length > 0
        msg = JSON.parse line
        if msg.sub?
          log.debug "client #{client.id} subscribes to #{msg.sub}"
          client.subs[msg.sub] = true
          (all_subs[msg.sub] or= {})[client.id] = true
        else if msg.pub?
          log.debug "client #{client.id} publishes #{msg.pub.msg} to #{msg.pub.chan}"
          for client_id, _ of (all_subs[msg.pub.chan] or {})
            log.debug "forwarding message to client #{client_id}"
            clients[client_id].write JSON.stringify(msg) + CRLF
        else
          throw new Error 'unknown msg type'
    catch err
      log.error "client #{client.id}: #{err.toString()}"
      client.destroy()

  client.on 'close', () =>
    log.debug "client #{client.id} closed"
    for chan, _ of client.subs
      delete all_subs[chan][client.id]
      delete all_subs[chan] if all_subs[chan].length == 0
    delete clients[client.id]

[host, port] = argv.listen.split ':'

server.listen port, host, () ->
  log.info "simple pubsub server listening on #{host}:#{port}"

process.on 'uncaughtException', (err) ->
  log.error "uncaught exception! #{err.toString()}"
  for client in clients
    client.write JSON.stringify(msg:{msg:err.toString(), chan:'simplepubsub'}) + CRLF
