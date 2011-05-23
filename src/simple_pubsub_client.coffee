net = require 'net'
EventEmitter = require('events').EventEmitter

CRLF = '\r\n'

class SimplePubsubClient extends EventEmitter
  constructor: (port, host) ->
    @subs = {} # chan => Function
    @sock = net.createConnection port, host
    @sock.on 'connect', () =>
      @sock.setTimeout 0
      @sock.setKeepAlive true
      @sock.setEncoding 'utf8'
    @sock.on 'data', (data) =>
      lines = data.split '\r\n'
      try
        for line in lines
          continue unless line.length > 0
          obj = JSON.parse line
          if obj.pub?
            @emit 'message', obj.pub.msg, obj.pub.chan
            @subs[obj.pub.chan] obj.pub.msg, obj.pub.chan if @subs[obj.pub.chan]
          else
            throw new Error 'unknown message type'
      catch err
        console.error err
        @emit 'protocol-error', err
        @sock.destroy()

  _write: (what) ->
    try
      @sock.write JSON.stringify(what) + CRLF
      true
    catch err
      console.error err
      @emit 'io-error', err
      @sock.destroy()
      false

  subscribe: (chan, cb) -> @subs[chan] = cb if @_write sub:chan
  publish: (msg, chan) -> @_write pub:{msg:msg, chan:chan}
  close: -> @sock.close()

exports.connect = (port=9912, host='127.0.0.1') ->
  new SimplePubsubClient port, host
