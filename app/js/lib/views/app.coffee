ELA.Views ?= {}
class ELA.Views.App extends Backbone.View
  initialize: ->
    @subviews = {}
    @listenTo @model, 'change:currentAppModel', @render
    @listenTo @model, 'change:showAbout', @renderAbout

  # @returns BaseApp or BaseSubappContainer
  currentAppModel: -> @model.currentAppModel()

  activateSubviews: =>
    if @currentAppModel()
      @subviews.index?.deactivate()
      @subviews.app?.activate()
    else
      @subviews.index?.activate()
      @subviews.app?.deactivate()

  loadedViewName: ->
    @subviews.app?.model.name

  currentAppModelName: ->
    @model.currentAppModel()?.name

  renderAbout: =>
    showAbout = @model.get('showAbout')
    if showAbout and not @subviews.help?
      @subviews.help = view = new ELA.Views.Help
        model: @model
      @$el.append(view.render().el)

    delay =>
      @subviews.help?.setActive(showAbout)
      @subviews.index?.setActive(not showAbout)

  render: =>
    unless @subviews.index?
      @subviews.index = new ELA.Views.Overview()
      @$el.append(@subviews.index.render().el)

    if @subviews.app and @loadedViewName() isnt @currentAppModelName()
      @subviews.app.remove()
      delete @subviews.app

    if @model.currentAppModel() and not @subviews.app?
      AppView = @model.currentNamespace().Views.App
      @subviews.app = view = new AppView
        model: @model.currentAppModel()
        localePrefix: @model.currentAppModel().localePrefix()
      @$el.append(view.render().el)

    @renderAbout()

    delay @activateSubviews

    this
