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

    @layout = options.layout or
      [ _.map(@views, (view, idx) -> String.fromCharCode(97 + idx)).join(' ') ]

  _style: ->
    'grid-template-areas: "' + @layout.join('" "') + '";' +
      'grid-auto-columns: ' +
      Array(@layout[0].split(' ').length).fill('1fr').join(' ') + ';' +
      'grid-auto-rows: ' +
      Array(@layout.length).fill('1fr').join(' ') + ';'


  render: ->
    @$el.empty().attr('style', @_style())

    for view, idx in @views
      options = _.extend
        model: @model
        parentView: this
        localePrefix: @localePrefix
        attributes:
          style: "grid-area: #{String.fromCharCode(97 + idx)}"
      , view.options
      view = @subviews[view.options.name] ?= new view.View(options)
      @$el.append(view.render().el)

    this
