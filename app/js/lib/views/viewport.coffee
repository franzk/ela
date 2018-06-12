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

    @layouts = options.layouts

    @listenTo(@model, 'change:layout', @render)

  areaLayout: ->
    '"' + @layouts[@model.get('layout')].layout.join('" "') + '"'

  _style: ->
    "grid-template-areas: #{@areaLayout()};" +
      'grid-auto-columns: 1fr;' +
      'grid-auto-rows: 1fr;'

  render: ->
    for view in @views
      @subviews[view.options.name]?.remove()

    @$el.empty().attr('style', @_style())

    for view, idx in @views
      area = String.fromCharCode(97 + idx)
      if @areaLayout().indexOf(area) > -1
        options = _.extend
          model: @model
          parentView: this
          localePrefix: @localePrefix
          attributes:
            style: "grid-area: #{area}"
        , view.options
        view = @subviews[view.options.name] = new view.View(options)
        @$el.append(view.render().el)

    this
