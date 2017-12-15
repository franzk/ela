class Backbone.Poised.Anchor extends Backbone.Poised.View
  tagName: 'div'
  className: 'poised anchor'

  initialize: (options = {}) =>
    throw new Error('Missing `anchor` option') unless options.anchor?

    @anchor = options.anchor
    @label = options.label

    @collapsible = options.collapsible is true
    @collapsed = options.collapsed isnt false if @collapsible

  toggleCollapse: =>
    @$el.toggleClass('collapsed')

  render: =>
    @$el.html @label or @loadLocale "formAnchor.#{@anchor}.label",
      defaultValue: @anchor.toLabel()

    if @collapsible
      @$el.addClass('collapsible')
      @toggleCollapse() if @collapsed
      @$el.on('tap', @toggleCollapse)

    this
