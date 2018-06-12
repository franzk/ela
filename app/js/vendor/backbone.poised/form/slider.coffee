window.poisedCurrentSlider = null

class Backbone.Poised.Slider extends Backbone.Poised.View
  template: _.template('<div class="bar"></div><div class="handle"></div>')

  className: 'poised slider'

  startValue: 0
  range: 100

  events:
    'tap': 'handleTap'
    'panstart': 'handlePanStart'
    'press': 'handlePress'
    'pan': 'handlePan'
    'panend': 'handlePanEnd'
    'pressup': 'handlePanEnd'

  hammerjs:
    recognizers: [
      [Hammer.Rotate, { enable: false }],
      [Hammer.Pinch, { enable: false }, ['rotate']],
      [Hammer.Swipe, { enable: false }],
      [Hammer.Pan, { direction: Hammer.DIRECTION_HORIZONTAL, threshold: 1 }, ['swipe']],
      [Hammer.Tap, { threshold: 5 }],
      [Hammer.Press]
    ]

  initialize: (options = {}) =>
    throw new Error('Missing `model` option') unless options.model?
    throw new Error('Missing `attribute` option') unless options.attribute?

    @attribute = options.attribute

    options = _.chain(options)
      .pick('maxValue', 'minValue', 'stepSize')
      .defaults
        minValue: 0
        maxValue: 100
        stepSize: 1
      .value()

    @range = options.maxValue if options.maxValue?

    if options.minValue?
      @startValue = options.minValue
      @range -= options.minValue

    @stepSize = options.stepSize

    @listenTo(@model, "change:#{@attribute}", @updateHandlePosition)

  # TODO: Save previously focused element and resore focus after
  # slider action finished.
  clearFocus: ->
    $('input').blur()

  handleTap: (e) ->
    touchPosition = e.gesture.center.x - @$bar.offset().left
    @model.set @attribute, @calculateAttributeValue(touchPosition)
    @trigger('tapChange', this)

  isPanning: false

  startLiveChange: =>
    @isPanning = true
    @clearFocus()
    @trigger('liveChangeStart', this)

  handlePanStart: (e) =>
    if Math.abs(e.gesture.deltaX) > Math.abs(e.gesture.deltaY) and not @isPanning
      @startLiveChange()

  handlePress: (e) =>
    @startLiveChange()
    @handlePan(e)

  handlePan: (e) =>
    if @isPanning
      touchPosition = e.gesture.center.x - @$el.offset().left
      @model.set @attribute, @calculateAttributeValue(touchPosition)
      @trigger('liveChange', this)

  handlePanEnd: (e) =>
    if @isPanning
      @trigger('liveChangeEnd', this)
      @isPanning = false

  calculateAttributeValue: (position) ->
    barWidth = @$bar.width()
    position = Math.max(position, 0)
    position = Math.min(position, barWidth)
    @startValue + Math.round((@range * position / barWidth) / @stepSize) * @stepSize

  calculateHandlePosition: ->
    val = Math.max(@model.get(@attribute), @startValue)
    val = Math.min(val, @startValue + @range)
    (val - @startValue) / @range * 100

  updateHandlePosition: ->
    @$handle.css('left', "#{@calculateHandlePosition().toFixed(2)}%")

  render: =>
    @$el.html @template()
    @$handle = @$el.find('.handle')
    @$bar    = @$el.find('.bar')
    @updateHandlePosition()
    this
