class Backbone.Poised.Textfield extends Backbone.View
  className: 'poised textfield'

  events:
    'focusin input': 'clearInputValue'
    'focusout input': 'readInput'
    'keyup input': 'handleKeyUp'

  initialize: (options = {}) =>
    throw new Error('Missing `model` option') unless options.model?
    throw new Error('Missing `attribute` option') unless options.attribute?

    @attribute = options.attribute

    @options = _.chain(options)
      .pick('type', 'placeholder', 'autofocus', 'clearOnFocus', 'stepSize', 'precision', 'minValue', 'maxValue', 'unit', 'validate')
      .defaults
        type: 'text'
        autofocus: false
        clearOnFocus: false
        minValue: null
        maxValue: null
        validate: true
      .value()

    if @options.stepSize? and not @options.precision?
      @options.precision = _.find([0..3], (i) =>
        @options.stepSize * Math.pow(10, i) >= 1)

    if _.isArray(options.range)
      [@options.minValue, @options.maxValue] = options.range

    @listenTo(@model, "change:#{@attribute}", @setValue)

  limit: (val) ->
    val = Math.max(val, @options.minValue) if @options.minValue?
    val = Math.min(val, @options.maxValue) if @options.maxValue?
    val

  _updateValue: (value = @model.get(@attribute), options = {}) =>
    if @options.type is 'number'
      if typeof value is 'string'
        if value.match(/^[+\-]?\d+(\.\d+)?$/i)?
          value = @limit(parseFloat(value))
        else
          value = @model.get(@attribute)

      if @options.precision?
        valueString = value.toFixed(@options.precision)

    @$input.val(valueString or value)

    unless options.updateModel is false
      @model.set(@attribute, value)

      if @model.validate? and @options.validate
        @model.validate(@attribute)

  setValue: ->
    return if @$input.is(':focus')
    @_updateValue(undefined, updateModel: false)

  handleKeyUp: (e) =>
    @readInput() if e.keyCode == 13

  readInput: =>
    @_updateValue(@$input.val())
    @trigger('changeValue')

  clearInputValue: =>
    @$input.val('') if @options.clearOnFocus

  render: =>
    @$el.empty()

    inputAttributes =
      class: 'poised'
      name: @attribute
      type: @options.type
      placeholder: @options.placeholder
      autofocus: @options.autofocus

    if @options.type is 'number'
      inputAttributes.min  = @options.minValue
      inputAttributes.max  = @options.maxValue
      inputAttributes.step = @options.stepSize or 'any'

    @$input = $('<input />', inputAttributes).appendTo(@$el)

    @$el.append($('<abbr/>', text: @options.unit)) if @options.unit

    @_updateValue()
    this
