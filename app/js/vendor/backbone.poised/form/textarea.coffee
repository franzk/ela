class Backbone.Poised.Textarea extends Backbone.Poised.View
  tagName: 'span'
  className: 'poised textarea'

  events:
    'input textarea': 'updateAttributeValue'

  initialize: (options = {}) =>
    throw new Error('Missing `model` option') unless options.model?
    throw new Error('Missing `attribute` option') unless options.attribute?

    @options = _.chain(options)
      .pick('rows', 'placeholder')
      .defaults
        rows: 3
        placeholder: null
      .value()

    @attribute = options.attribute

    @model.on "change:#{@attribute}", @render

  updateAttributeValue: =>
    @model.set(@attribute, @$textarea.val())

  updateTextareaValue: (model, value) =>
    val = value or @model.get(@attribute)
    @$textarea.val(val)

  render: =>
    @$textarea = $ '<textarea>', @options
    @$el.html(@$textarea)

    @updateTextareaValue()

    this
