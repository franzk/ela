ELA.Views ?= {}
class ELA.Views.AxisHandler extends Backbone.Poised.View
  className: 'axis-handler'

  events:
    'pan': 'updateValue'
    'tap': 'updateValue'

  hammerjs:
    recognizers: [
      [Hammer.Rotate, { enable: false }],
      [Hammer.Pinch, { enable: false }, ['rotate']],
      [Hammer.Swipe, { enable: false }],
      [Hammer.Pan, { direction: Hammer.DIRECTION_ALL, threshold: 1 }, ['swipe']],
      [Hammer.Tap, { threshold: 5 }],
      [Hammer.Press, { enable: false }]
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

    @listenTo @model, "change:#{@attribute}", @renderText

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
    @model.set(@attribute, point)

  renderText: =>
    @$el.find('span').text(t(
      "#{@model.name}.axisHandler.#{@attribute}.label"
      "#{@model.name}.axisHandler.label"
      'axisHandler.label'
      value: @model.get(@attribute).toFixed(@precision)
    ))

  render: =>
    @$el.html('<span class="hint"></span>')
    @$el.addClass("axis-handler-#{@position}")
    @renderText()
    this
