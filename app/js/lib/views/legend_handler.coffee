ELA.Views ?= {}
class ELA.Views.LegendHandler extends Backbone.Poised.View
  events:
    'pan': 'updateRange'
    'tap': 'updateRange'

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
    super
    @axis = options.axis or 'x'
    @attribute = options.attribute or @axis
    @precision = @model.get('valueAtRangePrecision') # TODO: Make this obsolete
    @precision ?= options.precision
    @precision ?= 2

    @listenTo @model, "change:#{@attribute}", @renderText

  updateRange: (e) =>
    origin = @model.displayParams.get("#{@axis}Origin")
    range = @model.displayParams.get("#{@axis}Range")
    if @axis is 'x'
      width = @model.displayParams.get('width')
      point = (range / width) * (e.gesture.pointers[0].clientX - origin)
    else
      height = @model.displayParams.get('height')
      y = e.gesture.pointers[0].clientY - @$el.offset().top
      y = Math.min(Math.max(y, 0), height)
      point = (range / height) * (origin - y)

    pow = Math.pow(10, @precision)
    point = Math.round(point * pow) / pow
    @model.set(@attribute, point)

  renderText: =>
    @$el.find('span').text(t(@model.name + '.legendHandler.label', 'legendHandler.label', value: @model.get(@attribute).toFixed(@precision)))

  render: =>
    @$el.html('<span class="hint"></span>')
    @$el.toggleClass('orientation-x', @axis is 'x')
    @$el.toggleClass('orientation-y', @axis is 'y')
    @renderText()
    this
