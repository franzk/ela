class Backbone.Poised.List.AddButton extends Backbone.Poised.View
  tagName: 'li'
  className: 'add button'

  events:
    'tap': 'add'

  initialize: ({@label}) ->
    super

  add: =>
    @trigger('add')

  render: ->
    @$el.html(@label)
    this
