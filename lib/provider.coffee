{ Directory, File } = require 'atom'
md5 = require 'md5'
q = require 'q'
request = require 'request'

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
      projectPath = getOwnerProject(editor.getPath())
      port = getPortForProject(projectPath)
      request {
        method: 'POST',
        uri: 'http://localhost:' + (port ? 6070),
        json: body
      }, (error, response, body) ->
        suggestions = []
        if error?
          console.debug error
          updateServersList()
        else if response.statusCode is 404
          updateServersList()
        else
          result = if typeof body is 'object' then body else parseBody(body)
          if result['suggestions']? and result['suggestions'].length > 0
            suggestions = for s in result['suggestions'] ? []
              suggestion =
                text: s
                replacementPrefix: result['prefix'] ? prefix
          else if result['hint']?
            hint = result['hint']
            inlineHint = hint.replace /[\r\n]/gm, ""
            parserArgs = /\((.*?)\)/g.exec(inlineHint)
            if parserArgs?
              args = []
              i = 1
              for arg in parserArgs[1].split ","
                args.push "${#{i}:#{arg.trim()}}"
                i++
              inlineHint = args.join ", "
            suggestions = [
              suggestion =
                snippet: inlineHint
                description: result['hint']
                replacementPrefix: result['prefix'] ? prefix
            ]
        deferred.resolve suggestions
      deferred.promise

parseBody = (body) ->
  try
    JSON.parse(body)
  catch error
    console.debug 'Cannot parse server response body as JSON'
    []

getOwnerProject = (filePath) ->
  for project in @projectsCache ? []
    if filePath.startsWith(project)
      return project

  currentDir = new File(filePath).getParent()
  while not currentDir.getFile("engine.cfg").existsSync()
    currentDir = currentDir.getParent()

  if currentDir.isRoot()
    undefined
  else
    ownerProject = currentDir.getPath()
    if @projectsCache? and ownerProject not in @projectsCache
      @projectsCache.push currentDir.getPath()
    ownerProject

getPortForProject = (projectPath) ->
  if projectPath? then @serversList?[md5(projectPath)] else undefined

updateServersList = () ->
  new File(getServersListPath()).read(true).then (fileContent) ->
    if fileContent?
      @serversList = JSON.parse(fileContent)

getServersListPath = () ->
  if process.env.APPDATA?
    process.env.APPDATA + "/Godot/.autocomplete-servers.json"
  else if process.env.HOME?
    process.env.HOME + "/.godot/.autocomplete-servers.json"
