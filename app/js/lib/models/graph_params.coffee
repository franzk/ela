ELA.Models ?= {}
class ELA.Models.GraphParams extends ELA.Models.CanvasParams
  defaults:
    xScale: 1.1 # display 10% more than the configured xRange
    yScale: 1.1 # display 10% more than the configured yRange
    xOrigin: 8 + 12 + 8
    yOrigin: 8 + 12 + 8
    xOriginAnchor: 'left'
    yOriginAnchor: 'bottom'
    xOriginRatio: null
    yOriginRatio: null
    yOffset: 0
    debug: {}
    xLabelPosition: 'top'
    yLabelPosition: 'right'
    xPanLocked: false
    yPanLocked: false
    xPinchLocked: false
    yPinchLocked: false
    scaleLink: false
    xAxisY: 0
    xAxisScale: { type: 'linear' }
    yAxisX: 0
    yAxisScale: { type: 'linear' } # not implemented yet

  constructor: ->
    super

    if @defaults.xOriginRatio? and @defaults.xOriginAnchor is 'right'
      @defaults.xOriginRatio = 1 - @defaults.xOriginRatio
      @defaults.xOriginAnchor = 'left'

    if @defaults.yOriginRatio? and @defaults.yOriginAnchor is 'bottom'
      @defaults.yOriginRatio = 1 - @defaults.yOriginRatio
      @defaults.yOriginAnchor = 'top'

  initialize: ->
    # Place origin when width and height are being set for the first
    # time
    @once('change:width change:height', @reset)
    @on('change:width change:height', @resize)

    # @calculateRanges changes params.xyRange
    @on('change:xScale', @calculateRanges)
    @on('change:yScale', @calculateRanges)

    @calculateRanges()
    @bindCalculatorEvents()
    @listenTo(@app.curves, 'change:selected', @bindCalculatorEvents)
    @listenTo @app, 'change:calculators', ->
      @calculateRanges()
      @bindCalculatorEvents()

  bindCalculatorEvents: ->
    # Remove current callbacks, add new ones for each curve
    @stopListening(@app.previous('calculators'))

    for calc in @app.get('calculators')
      filteredCurves = @filteredCurves()
      for curve in filteredCurves
        @listenTo calc, "change:#{curve.get('function')}", ->
          @trigger('repaint')

      @listenTo(calc, 'change:maxX change:xRange', @calculateRangeX)
      @listenTo(calc, 'change:maxY change:yRange', @calculateRangeY)
      # TODO: Add dynamic dependencies to calculator, so that we can
      # actually only listen to maxY changes and recalculate ranges.
      oldestCurve = filteredCurves[0]
      if oldestCurve?
        @listenTo(calc,
          "change:#{oldestCurve.get('function')}"
          @calculateRanges
        )

  reset: ->
    if (xOriginRatio = @get('xOriginRatio'))?
      @set(xOrigin: @get('width') * xOriginRatio)
    else if @get('xOriginAnchor') is 'left'
      @set(xOrigin: @defaults.xOrigin)
    else
      @set(xOrigin: @get('width') - @defaults.xOrigin)

    if (yOriginRatio = @get('yOriginRatio'))?
      @set(yOrigin: @get('height') * yOriginRatio)
    else if @defaults.yOriginAnchor is 'bottom'
      @set(yOrigin: @get('height') - @defaults.yOrigin)
    else
      @set(yOrigin: @defaults.yOrigin)

    if @get('scaleLink')
      # axis with less pixels per unit length should define scale
      if @get('width') / @maxRangeX(null, 1) < @params.get('height') / @maxRangeY(null, 1)
        @set(yScale: @linkedYScale(xScale))
      else
        @set(xScale: @linkedXScale(yScale))
    else
      @set(xScale: @defaults.xScale, yScale: @defaults.yScale)

  resize: ->
    previous = @previousAttributes()
    if previous.width? and previous.height?
      previousXOrigin = if previous.xOrigin?
        previous.xOrigin
      else
        @get('xOrigin')
      previousYOrigin = if previous.yOrigin?
        previous.yOrigin
      else
        @get('yOrigin')
      @set
        xOrigin: previousXOrigin * @get('width') / previous.width
        yOrigin: previousYOrigin * @get('height') / previous.height

      switch @get('scaleLink')
        when 'x'
          @set xScale: @linkedXScale()
        when 'y'
          @set yScale: @linkedYScale()
    else
      @reset()

  calculateRangeX: ->
    @set(xRange: @maxRangeX())

  calculateRangeY: ->
    @set(yRange: @maxRangeY())

  calculateRanges: ->
    @calculateRangeX()
    @calculateRangeY()

  maxRangeX: (func, xScale = @get('xScale')) ->
    func = @get('axisLabelingForCurve')?.get('function') unless func?
    ranges = (calc.xRange(func) for calc in @app.get('calculators'))
    Math.max.apply(Math, _.compact(ranges)) * xScale

  maxRangeY: (func, yScale = @get('yScale')) ->
    func = @get('axisLabelingForCurve')?.get('function') unless func?
    ranges = (calc.yRange(func) for calc in @app.get('calculators'))
    Math.max.apply(Math, _.compact(ranges)) * yScale

  linkedXScale: (yScale) ->
    # calculate xScale to fulfill the following equation:
      # (width / maxRangeX) / xScale = height / maxRangeY
    (@get('width') / @maxRangeX(null, 1)) /
    (@get('height') / @maxRangeY(null, yScale))

  linkedYScale: (xScale) ->
    # calculate yScale to fulfill the following equation:
      # (height / maxRangeY) / yScale = width / maxRangeX
    (@get('height') / @maxRangeY(null, 1)) /
    (@get('width') / @maxRangeX(null, xScale))

  filteredCurves: ->
    curves = @app.curves.history
    if graphCurves = @get('curves')
      _.filter curves, (curve) ->
        graphCurves.indexOf(curve.get('function')) >= 0
    else
      curves

  sortedCurves: ->
    _.sortBy @filteredCurves(), (curve) ->
      curve.get('zIndex')

  serialize: ->
    xScale: @get('xScale')
    yScale: @get('yScale')
    xOriginRatio: @get('xOrigin') / @get('width')
    yOriginRatio: @get('yOrigin')  / @get('height')

  deserialize: (attributes) ->
    @set
      xScale: attributes.xScale
      yScale: attributes.yScale
      xOrigin: @get('width') * attributes.xOriginRatio
      yOrigin: @get('height') * attributes.yOriginRatio
