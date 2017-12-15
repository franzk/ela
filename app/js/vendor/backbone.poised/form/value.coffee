class Backbone.Poised.Value extends Backbone.Poised.View
  tagName: 'span'
  className: 'poised value'

  initialize: (options = {}) =>
    throw new Error('Missing `model` option') unless options.model?
    throw new Error('Missing `attribute` option') unless options.attribute?

    @attribute = options.attribute
    @options = _.chain(options)
      .pick('unit', 'precision')
      .value()

    @model.on "change:#{@attribute}", @render

  value: ->
    v = @model.get(@attribute)
    if typeof v is 'number' and isNaN(v)
      '-'
    else if @options.precision?
      @model.get(@attribute).toFixed(@options.precision)
    else
      v

  unit: ->
    if @options.unit
      " #{@options.unit}"
    else
      ''

  render: =>
    @$el.html("#{@value()}#{@unit()}")
    this
