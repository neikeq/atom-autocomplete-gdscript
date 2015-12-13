{CompositeDisposable} = require 'atom'
provider = require './provider'

module.exports =
  config:
    providerPriority:
      title: 'Provider Priority'
      description: 'Requires disabling and enabling back the package'
      type: 'integer'
      default: 2
    excludeLowerProviders:
      title: 'Exclude Lower Priority Providers'
      description: 'If enabled, only suggestions by this provider will be displayed'
      type: 'boolean'
      default: true

  activate: (state) ->
    provider.constructor()
    updateSettingsCallback = ->
      provider?.inclusionPriority = atom.config.get('autocomplete-gdscript.providerPriority')
      provider?.excludeLowerPriority = atom.config.get('autocomplete-gdscript.excludeLowerProviders')
    updateSettingsCallback.call
    @subscriptions = new CompositeDisposable
    @subscriptions.add(atom.config.onDidChange('autocomplete-gdscript', updateSettingsCallback))

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  provide: -> provider
