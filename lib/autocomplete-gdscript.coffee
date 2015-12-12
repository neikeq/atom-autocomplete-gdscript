provider = require './provider'

module.exports =
  activate: (state) -> provider.constructor()

  deactivate: ->

  provide: -> provider
