Backbone.Poised.List ||= {}
class Backbone.Poised.List.Anchor extends Backbone.Poised.View
  tagName: 'li'
  className: 'anchor'

  events:
    'click': 'toggleCollapse'

  initialize: (options = {}) ->
    super
    @name = options.name or 'general'
    @label = options.label

    @collapsible = options.collapsible is true
    @collapsed = options.collapsed isnt false if @collapsible

  toggleCollapse: =>
    @$el.toggleClass('collapsed')

  render: ->
    if @name is 'undefined'
      defaultLocale = 'other'
    else
      defaultLocale = @name.toLabel()
    @$el.html @loadLocale "listAnchors.#{@name}.label",
      defaultValue: defaultLocale

    if @collapsible
      @$el.addClass('collapsible')
      @toggleCollapse() if @collapsed

    this
