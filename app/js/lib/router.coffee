class ELA.Router extends Backbone.Router
  routes:
    '': 'index'
    '(app/)*path': 'load'

  initialize: ->
    ELA.store = new Persist.Store('ilr_app')
    ELA.app = new ELA.Models.App()
    ELA.view = new ELA.Views.App
      model: ELA.app
      el: $('#app')
    ELA.view.render()

  index: ->
    ELA.app.set(path: null)

  load: (path, params) ->
    if params?
      try
        params = JSON.parse(decodeURI(params))
      catch
        alert(t('messages.invalidParameters'))
        params = null
    ELA.app.set
      path: path.split('/')
      params: params
