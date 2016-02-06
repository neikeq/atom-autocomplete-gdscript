request = require 'request'
q = require 'q'

module.exports =
  provider =
    selector: '.source.gdscript'
    disableForSelector: '.punctuation.definition.comment.gdscript'

    inclusionPriority: 2
    excludeLowerPriority: true

    getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix, activatedManually}) ->
      deferred = q.defer()
      body =
        path: editor.getPath()
        text: editor.getText()
        cursor: {
          row: bufferPosition['row']
          column: bufferPosition['column']
        }
        meta: ''
      request {
        method: 'POST',
        uri: 'http://localhost:6070',
        json: body
      }, (error, response, body) =>
        suggestions = []
        if error?
          console.debug error
        else
          result = if typeof body is 'object' then body else parseBody(body)
          suggestions = if result['suggestions']? then for s in result['suggestions']
            suggestion =
              text: s
              replacementPrefix: if result['prefix']? then result['prefix'] else prefix
        deferred.resolve suggestions
      deferred.promise

    parseBody: (body) ->
      try
        JSON.parse(body)
      catch error
        console.debug 'Cannot parse server response body as JSON'
        []
