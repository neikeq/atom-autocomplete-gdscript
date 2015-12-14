{CompositeDisposable} = require 'atom'
provider = require './provider'

module.exports =
  config:
    providerPriority:
      title: 'Provider Priority'
      description: 'Requires disabling and enabling the package back'
      type: 'integer'
      default: 2
    lowerProvidersBehaviour:
      title: 'Lower Priority Providers Suggestions'
      description: 'Suggestions inclusion behaviour for lower priority providers'
      type: 'string'
      default: 'Exclude All'
      enum: ['Include All', 'Exclude All', 'Exclude lang-gdscript']

  activate: (state) ->
    provider.constructor()
    updateSettingsCallback = ->
      provider?.inclusionPriority = atom.config.get('autocomplete-gdscript.providerPriority')
      lowerProvidersBehaviour = atom.config.get('autocomplete-gdscript.lowerProvidersBehaviour')
      provider?.excludeLowerPriority = lowerProvidersBehaviour is 'Exclude All'
      atom.config.set('lang-gdscript.disableBasicCompletions', lowerProvidersBehaviour is 'Exclude lang-gdscript')
    updateSettingsCallback.call
    @subscriptions = new CompositeDisposable
    @subscriptions.add(atom.config.onDidChange('autocomplete-gdscript', updateSettingsCallback))

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  provide: -> provider
