{time} = require './misc'

module.exports =
  client:   require './connection/client'
  process:  require './connection/process'
  tcp:      require './connection/tcp'
  terminal: require './connection/terminal'

  activate: ->
    @client.activate()
    @client.boot = => @boot()
    @process.activate()

  deactivate: ->

  consumeInk: (ink) ->
    @client.loading = new ink.Loading

  metrics: ->
    try
      if id = localStorage.getItem 'metrics.userId'
        require('http').get "http://data.junolab.org/hit?id=#{id}&app=atom-julia-boot"

  boot: ->
    if not @client.isActive()
      @tcp.listen (port) => @process.start port
      time "Julia Boot", @client.rpc('ping').then => @metrics()
