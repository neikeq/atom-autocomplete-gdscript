cson = require 'cson-safe'
request = require 'request'
q = require 'q'

module.exports =
    provider =
        selector: '.source.gdscript'
        disableForSelector: '.punctuation.definition.comment.gdscript'

        # This will take priority over lang-gdscript provider, which has a priority of 2
        inclusionPriority: 2
        excludeLowerPriority: true

        getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix, activatedManually}) ->
            deferred = q.defer()

            body =
                path: editor.getPath()
                text: editor.getText()
                cursor: {
                    row: bufferPosition["row"]
                    column: bufferPosition["column"]
                }
                meta: ""

            reque = request {
                method: "POST",
                uri: "http://localhost:6070",
                json: body
            }, (error, response, body) =>
                suggestions = []
                if error?
                    console.debug error
                else
                    result = []
                    if typeof body is 'object'
                        result = body
                    else
                        try
                            result = JSON.parse(body)
                        catch error
                            console.debug "Cannot parse response body"

                    if result["suggestions"]?
                        suggestions = for s in result["suggestions"]
                            suggestion =
                                text: s
                                replacementPrefix: if result["prefix"]? then result["prefix"] else prefix
                deferred.resolve suggestions
            deferred.promise
