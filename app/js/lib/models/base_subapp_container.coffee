ELA.Models ?= {}
class ELA.Models.BaseSubappContainer extends ELA.Models.BaseAppModel
  subapps: {}

  initialize: (options = {}) ->
    @subappInstances = {}

    for name, app of @subapps
      AppModel = app.model.toFunction()
      @subappInstances[name] = new AppModel
        parentApp: this

    @on 'change:path', @handlePath
    @handlePath()

  handlePath: =>
    path = @get('path')
    subapp = path[0]
    if _.isEmpty(path)
      subappPath = @subappInfo()[0].path
      ELA.router.navigate "app/#{subappPath}",
        trigger: false
        replace: true
      [..., last] = subappPath.split('/')
      path.push(last)

    @subappInstances[subapp]?.set(path: path.slice(1))

  subappInfo: ->
    for name, app of @subappInstances
      name: app.name
      path: app.path

  currentApp: ->
    @subappInstances[@get('path')[0]]
