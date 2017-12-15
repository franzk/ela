ELA.Models ?= {}
class ELA.Models.App extends Backbone.Model
  helpText: 'about'

  defaults:
    path: null
    params: null
    showAbout: false

  initialize: ->
    @on('change:path', @handlePath)
    @on('change:params', @handleParams)

  # @returns BaseApp or BaseSubappContainer
  currentAppModel: ->
    @get('currentAppModel')

  # @returns BaseApp
  currentApp: ->
    @currentAppModel()?.currentApp()

  currentNamespace: ->
    path = @get('path')
    if path?
      klass = path[0].toCapitalCamel()
      ELA[klass]

  handlePath: (model, path) ->
    if path?
      if path[0] is 'about'
        @set(showAbout: true)
      else if path[0] isnt @currentAppModel()?.name
        AppClass = @currentNamespace().Models.App
        @set
          showAbout: false
          currentAppModel: new AppClass(path: path.slice(1))
      else
        @currentAppModel()?.set(path: path.slice(1))
        @set(showAbout: false)
    else
      @set
        currentAppModel: null
        showAbout: false

  handleParams: (model, params) ->
    @currentApp().deserialize(params) if params?

  url: ->
    url = location.origin
    if json = @toJSON()
      url += '/#app/' +
        @get('path').join('/') +
        '?' +
        encodeURI(json)
    url

  toJSON: ->
    JSON.stringify(currentApp.serialize()) if currentApp = @currentApp()
