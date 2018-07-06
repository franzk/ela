ELA.Views ?= {}
class ELA.Views.AxisHandler extends Backbone.Poised.View
  className: 'axis-handler'

  events:
    'pan': 'handlePan'
    'tap': 'handleTap'
    'press': 'showInputField'
    'pressup': 'focusInputField'
    'tap input': 'handleInputTap'

  hammerjs:
    recognizers: [
      [Hammer.Rotate, { enable: false }],
      [Hammer.Pinch, { enable: false }, ['rotate']],
      [Hammer.Swipe, { enable: false }],
      [Hammer.Pan, { direction: Hammer.DIRECTION_ALL, threshold: 10 }, ['swipe']],
      [Hammer.Tap, { threshold: 5 }],
      [Hammer.Press]
    ]

  initialize: (options) ->
    @displayParams = options.displayParams
    @position = options.position or 'bottom'
    @orientation = switch @position
      when 'bottom' then 'x'
      when 'left' then 'y'
    @attribute = options.attribute
    @precision = ELA.settings[@model.name]?.formFields?[@attribute]?.precision
    @precision ?= options.precision
    @precision ?= 2
    @maxValue = ELA.settings[@model.name]?.formFields?[@attribute]?.maxValue
    @maxValue ?= ELA.settings[@model.name]?.formFields?[@attribute]?.range?[1]
    @maxValue ?= options.maxValue
    @maxValue ?= options.range?[1]
    @minValue = ELA.settings[@model.name]?.formFields?[@attribute]?.minValue
    @minValue ?= ELA.settings[@model.name]?.formFields?[@attribute]?.range?[0]
    @minValue ?= options.minValue
    @minValue ?= options.range?[1]

    @listenTo(@model, "change:#{@attribute}", @renderSpan)

    @subviews = {}
    @formSettings = @model.loadSettings("formFields")[@attribute]
    @params = new Backbone.Model
      showInput: false
    @listenTo(@params, 'change:showInput', @renderSpan)

    @lastFocusOutAt = undefined

  handleTap: (e) =>
    @updateValue(e) unless @hasRecentlyOpenInput()

  handlePan: (e) =>
    @updateValue(e) unless @params.get('showInput')

  handleInputTap: (e) =>
    e.stopPropagation()

  updateValue: (e) =>
    origin = @displayParams.get("#{@orientation}Origin")
    range = @displayParams.get("#{@orientation}Range")
    graphOffset = @parentView.subviews.graph.$el.offset()
    if @orientation is 'x'
      width = @displayParams.get('width')
      point = (range / width) *
        (e.gesture.center.x - graphOffset.left - origin)
    else # @orientation is 'y'
      height = @displayParams.get('height')
      y = e.gesture.center.y - graphOffset.top
      y = Math.min(Math.max(y, 0), height)
      point = (range / height) * (origin - y)

    pow = Math.pow(10, @precision)
    point = Math.round(point * pow) / pow
    point = Math.max(point, @minValue) if isFinite(@minValue)
    point = Math.min(point, @maxValue) if isFinite(@maxValue)
    @model.set(@attribute, point)

  showInputField: ->
    @params.set(showInput: true)

  focusInputField: =>
    _.defer => @subviews.inputControl?.$('input').focus()

  closeInputField: =>
    @params.set(showInput: false)

  hasRecentlyOpenInput: ->
    # not (new Date - @lastFocusOutAt < 100) and (new Date - @lastFocusOutAt > 100)
    # are not equal when @lastFocusOutAt is undefined!
    @params.get('showInput') or (new Date - @lastFocusOutAt < 100)

  handleFocusOut: =>
    @lastFocusOutAt = new Date
    @closeInputField()

  text: (value) =>
    t(
      "#{@model.name}.axisHandler.#{@attribute}.label"
      "#{@model.name}.axisHandler.label"
      'axisHandler.label'
      value: "<span></span>"
    )

  renderSpan: =>
    if @params.get('showInput')
      @$label.addClass('has-input')
      control = new Backbone.Poised.Textfield(
        _.defaults(
          model: @model
          attribute: @attribute
          type: 'number'
        ,
          @formSettings
        )
      )
      @subviews.inputControl = control
      @listenToOnce(control, 'changeValue', @handleFocusOut)
      @$label.find('span').html(control.render().el)
    else
      @$label.removeClass('has-input')
      @$label.find('span').text(
        @model.get(@attribute).toFixed(@precision) + ' ' + @formSettings.unit
      )

  render: =>
    delete @subviews.inputField
    @$label = $('<label>').html(@text())
    @renderSpan()
    @$el.html(@$label)
    @$el.addClass("axis-handler-#{@position}")
    this
