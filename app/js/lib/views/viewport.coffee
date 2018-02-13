ELA.Views ?= {}

class ELA.Views.Viewport extends Backbone.Poised.View
  tagName: 'article'
  className: 'viewport'

  initialize: (options = {}) ->
    @views = for view in options.views
      view.options = _.omit(view, 'view')
      view.options.name = view.name or Math.random().toString(36).slice(-8)
      view.View = view.view?.toFunction() or ELA.Views.GraphView
      view

    @subviews = {}

  render: ->
    @$el.empty()
    for view in @views
      options = _.extend
        model: @model
        parentView: this
        localePrefix: @localePrefix
      , view.options
      view = @subviews[view.options.name] ?= new view.View(options)
      @$el.append(view.render().el)
    this
