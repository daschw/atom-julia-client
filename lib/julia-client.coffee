etch = require 'etch'

commands = require './package/commands'
menu = require './package/menu'
toolbar = require './package/toolbar'

module.exports = JuliaClient =
  misc:       require './misc'
  ui:         require './ui'
  connection: require './connection'
  runtime:    require './runtime'

  activate: (state) ->
    etch.setScheduler(atom.views)
    @requireInk =>
      commands.activate @
      x.activate() for x in [menu, @connection, @runtime]
      @ui.activate @connection.client

      require('./package/settings').updateSettings()

      if atom.config.get('julia-client.firstBoot')
        @ui.layout.queryStandardLayout()
      if atom.config.get('julia-client.useStandardLayout')
        setTimeout (=> @ui.layout.standard()), 150

  requireInk: (fn) ->
    if atom.packages.isPackageLoaded "ink" then fn()
    else
      require('atom-package-deps').install('julia-client')
        .then  -> fn()
        .catch ->
          atom.notifications.addError 'Installing the Ink package failed.',
            detail: 'Julia Client requires the Ink package to run.
                     Please install it manually from the settings view.'
            dismissable: true

  deactivate: ->
    x.deactivate() for x in [commands, menu, toolbar, @connection, @runtime, @ui]

  consumeInk: (ink) ->
    commands.ink = ink
    x.consumeInk ink for x in [@connection, @runtime, @ui]

  consumeTerminal: (term) ->
    @connection.consumeTerminal term

  consumeStatusBar: (bar) ->
    @runtime.consumeStatusBar bar

  consumeToolBar: (bar) -> toolbar.consumeToolBar bar

  provideClient: -> @connection.client

  provideHyperclick: -> @runtime.provideHyperclick()

  consumeAutocompleteWatchEditor: (watchEditor) ->
    @runtime.console.consumeAutocompleteWatchEditor(watchEditor)

  config: require './package/config'
  completions: -> @runtime.completions
