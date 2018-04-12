ELA.Views ?= {}
class ELA.Views.BaseGraph extends ELA.Views.Canvas
  class @Params extends Backbone.Model
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

  # A variable that contains temporary information about the pinch
  # or pan action that is currently performed.
  start: {}

  # Contains all view specific parameters that do not belong in the model.
  params: null

  # We need to cache current pixelRatio to reset the canvas scale.
  pixelRatio: null

  # Defaults for the view params model.
  defaults:
    xScale: 1.1 # display 10% more than the configured xRange
    yScale: 1.1 # display 10% more than the configured yRange
    xOrigin: 30
    yOrigin: 0
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
    xAxis: { y: 0 }
    yAxis: { x: 0 }

  initialize: ->
    super

    if @defaults.xOriginRatio? and @defaults.xOriginAnchor isnt 'left'
      @defaults.xOriginRatio = 1 - @defaults.xOriginRatio
      @defaults.xOriginAnchor = 'left'

    if @defaults.yOriginRatio? and @defaults.yOriginAnchor is 'bottom'
      @defaults.yOriginRatio = 1 - @defaults.yOriginRatio
      @defaults.yOriginAnchor = 'top'

    @resetCanvas()

    # @calculateRanges changes params.xyRange
    @params.on 'change:xScale', @calculateRangeX
    @params.on 'change:yScale', @calculateRangeY
    # When xyRange change we need to repaint
    @params.on 'change:xOrigin change:yOrigin change:yRange change:xRange change:width change:height', @requestRepaint

    @calculateRanges()

  calculateRangeX: =>
    @params.set xRange: @maxRangeX()

  calculateRangeY: =>
    @params.set yRange: @maxRangeY()

  calculateRanges: =>
    @calculateRangeX()
    @calculateRangeY()

  maxRangeX: (func, xScale = @params.get('xScale')) =>
    xScale * 5

  maxRangeY: (func, yScale = @params.get('yScale')) =>
    yScale * 5

  events:
    'pan': 'pan',
    'panstart': 'panstart'
    'panend': 'panend'
    'pinchstart': 'pinchstart'
    'pinch': 'pinch'
    'pinchend': 'pinchend'
    'doubletap': 'resetCanvas'
    'mousewheel': 'mousewheel'
    'DOMMouseScroll': 'mousewheel'

  hammerjs:
    recognizers: [
      [Hammer.Rotate, { enable: false }],
      [Hammer.Pinch, {}, ['rotate']],
      [Hammer.Swipe,{ enable: false }],
      [Hammer.Pan, { direction: Hammer.DIRECTION_ALL, threshold: 1 }, ['swipe']],
      [Hammer.Tap, { threshold: 5 }],
      [Hammer.Tap, { event: 'doubletap', taps: 2, posThreshold: 20, threshold: 5 }, ['tap']],
      [Hammer.Press, { enable: false }]
    ]

  mousewheel: (e) =>
    e.preventDefault()
    if e.originalEvent.wheelDelta > 0 or e.originalEvent.detail < 0
      factor = 1.05
    else
      factor = 0.95
    if not @params.get('xPinchLocked') and (not window.keys.ALT or window.keys.SHIFT or @params.get('scaleLink'))
      @params.set xScale: @params.get('xScale') * factor
    if not @params.get('yPinchLocked') and (@params.get('scaleLink') or window.keys.ALT or window.keys.SHIFT)
      @params.set yScale: @params.get('yScale') * factor

  # Set xScale/yScale and xOrigin/yOrigin to their default values.
  resetCanvas: =>
    clearTimeout(@panendTimeout)

    if @defaults.xOriginRatio?
      xOrigin = @params.get('width') * @defaults.xOriginRatio
    else if @defaults.xOriginAnchor is 'left'
      xOrigin = @defaults.xOrigin
    else
      xOrigin = @params.get('width') - @defaults.xOrigin

    if @defaults.yOriginRatio?
      yOrigin = @params.get('height') * @defaults.yOriginRatio
    else if @defaults.yOriginAnchor is 'bottom'
      yOrigin = @params.get('height') - @defaults.yOrigin
    else
      yOrigin = @defaults.yOrigin

    xScale = @defaults.xScale
    yScale = @defaults.yScale

    if @params.get('scaleLink')
      # axis with less pixels per unit length should define scale
      if @params.get('width') / @maxRangeX(null, 1) < @params.get('height') / @maxRangeY(null, 1)
         yScale = @linkedYScale(xScale)
      else
         xScale = @linkedXScale(yScale)

    @params.set
      xScale: xScale
      yScale: yScale
      xOrigin: xOrigin
      yOrigin: yOrigin

  linkedXScale: (yScale) =>
    # calculate xScale to fulfill the following equation:
    # (width / maxRangeX) / xScale = height / maxRangeY
    (@params.get('width') / @maxRangeX(null, 1)) / (@params.get('height') / @maxRangeY(null, yScale))

  linkedYScale: (xScale) =>
    # calculate yScale to fulfill the following equation:
    # (height / maxRangeY) / yScale = width / maxRangeX
    (@params.get('height') / @maxRangeY(null, 1)) / (@params.get('width') / @maxRangeX(null, xScale))

  debugCircle: (context, color, x, y, radius = 20) =>
    context.beginPath()
    context.arc(x,y,radius,0,2*Math.PI,false)
    context.fillStyle = color
    context.fill()
    context.closePath()

  centerBetweenTouches: (t1, t2) ->
    @centerBetweenPoints(t1.clientX, t1.clientY, t2.clientX, t2.clientY)

  centerBetweenPoints: (x1, y1, x2, y2) ->
    centerX = null
    if x1 <= x2
      centerX = x1 + (x2 - x1) / 2
    else
      centerX = x2 + (x1 - x2) / 2
    centerY = null
    if y1 <= y2
      centerY = y1 + (y2 - y1) / 2
    else
      centerY = y2 + (y1 - y2) / 2
    { x: centerX, y: centerY }

  pinchstart: (e) =>
    center = @centerBetweenTouches(e.gesture.pointers[0], e.gesture.pointers[1])
    @start.centerX = center.x
    @start.centerY = center.y
    @start.xOrigin = @params.get('xOrigin')
    @start.yOrigin = @params.get('yOrigin')
    @start.touchDistanceX = Math.max(50, Math.abs(e.gesture.pointers[0].clientX - e.gesture.pointers[1].clientX))
    @start.touchDistanceY = Math.max(50, Math.abs(e.gesture.pointers[0].clientY - e.gesture.pointers[1].clientY))
    @start.xScale = @params.get('xScale')
    @start.yScale = @params.get('yScale')

  pinch: (e) =>
    center = @centerBetweenTouches(e.gesture.pointers[0], e.gesture.pointers[1])
    deltaX = -(@start.centerX - center.x)
    deltaY = -(@start.centerY - center.y)

    touchDistanceX = Math.max(50, Math.abs(e.gesture.pointers[0].clientX - e.gesture.pointers[1].clientX))
    touchDistanceY = Math.max(50, Math.abs(e.gesture.pointers[0].clientY - e.gesture.pointers[1].clientY))
    xScale = touchDistanceX / @start.touchDistanceX
    yScale = touchDistanceY / @start.touchDistanceY

    xScale = yScale = (xScale + yScale)/2 if @params.get('scaleLink')

    unless @params.get('xPinchLocked')
      @params.set 'xScale', @start.xScale / xScale
    unless @params.get('yPinchLocked')
      @params.set 'yScale', @start.yScale / yScale
    unless @params.get('xPanLocked')
      @params.set xOrigin: @start.centerX + (@start.xOrigin - @start.centerX) * xScale + deltaX
    unless @params.get('yPanLocked')
      @params.set yOrigin: @start.centerY + (@start.yOrigin - @start.centerY) * yScale + deltaY

  pinchend: (e) =>
    # Do not call pan events on transformend
    @hammer.stop()
    # Reset temporary transform variables
    @start = {}

  panstart: =>
    clearTimeout(@panendTimeout)
    @start.xOrigin = @params.get('xOrigin')
    @start.yOrigin = @params.get('yOrigin')

  pan: (e) =>
    @start.xOrigin ||= @params.get('xOrigin')
    @start.yOrigin ||= @params.get('yOrigin')
    unless @params.get('xPanLocked')
      @params.set xOrigin: @start.xOrigin + e.gesture.deltaX
    unless @params.get('yPanLocked')
      @params.set yOrigin: @start.yOrigin + e.gesture.deltaY

  panend: (e) =>
    # Reset temporary transform variables
    @start = {}
    velocityX = e.gesture.velocityX * 10
    velocityY = e.gesture.velocityY * 10

    slowdown = =>
      if Math.abs(velocityX) > 0 and not @params.get('xPanLocked')
        @params.set xOrigin: @params.get('xOrigin') + velocityX
        velocityX *= 0.9
      if Math.abs(velocityY) > 0 and not @params.get('yPanLocked')
        @params.set yOrigin: @params.get('yOrigin') + velocityY
        velocityY *= 0.9
      if Math.abs(velocityY) > 0.2 or Math.abs(velocityX) > 0.2
        @panendTimeout = setTimeout(slowdown, 8)

    slowdown()

  # TODO: Create clever loops to fit with very small grids like
  # (0.00001) and very large grids like (10^10 or alike).
  roundStepSize: (stepSize) ->
    validStepSize = stepSize? and isFinite(stepSize)
    if validStepSize and stepSize > 0.5
      factor = 1
      loop
        for breakpoint in [1, 2, 5]
          roundedStepSize = breakpoint*factor
          return roundedStepSize if roundedStepSize > stepSize
        factor *= 10
    else if validStepSize and 0 < stepSize <= 0.5
      denominator = 10
      lastRoundedStepSize = null
      loop
        for breakpoint in [5, 2, 1]
          roundedStepSize = breakpoint/denominator
          if stepSize > roundedStepSize
            return lastRoundedStepSize or roundedStepSize
          else
            lastRoundedStepSize = roundedStepSize
        denominator *= 10
    else
      stepSize

  axisLabel: (value, stepSize) ->
    precision = 0
    precision += 1 while stepSize and stepSize*Math.pow(10, precision) < 1
    value.toFixed(precision)

  setCanvasResolution: (params) ->
    super

    # Recalculate xOrigin/yOrigin if we're in a width/height change
    # callback. Otherwise, we're initializing and we should skip that.
    if params?
      previous = @params.previousAttributes()
      previousXOrigin = if previous.xOrigin? then previous.xOrigin else @params.get('xOrigin')
      previousYOrigin = if previous.yOrigin? then previous.yOrigin else @params.get('yOrigin')
      @params.set
        xOrigin: previousXOrigin * @params.get('width') / previous.width
        yOrigin: previousYOrigin * @params.get('height') / previous.height

      # We don't need that during initialisation as well because it's
      # done by resetCanvas
      switch @params.get('scaleLink')
        when 'x'
          @params.set xScale: @linkedXScale()
        when 'y'
          @params.set yScale: @linkedYScale()

  xAxisValueLabel: (val, stepsize) ->
    @axisLabel(val, stepsize)

  yAxisValueLabel: (val, stepsize) ->
    @axisLabel(val - @params.get('yOffset'), stepsize)

  _axisLabel: (label) ->
    if typeof label is 'function'
      label.call(this)
    else if label?
      label
    else
      ''

  xAxisLabel: -> @_axisLabel(@params.get('xAxisLabel'))
  yAxisLabel: -> @_axisLabel(@params.get('yAxisLabel'))

  renderCurves: ->
    # stub

  renderXAxis: (y) ->
    @context.setLineDash []
    @context.font = @defaultFont
    @context.strokeStyle = "#999999"
    @context.fillStyle = "#000000"
    @context.lineWidth = 2

    @context.beginPath()
    yPos = @yOrigin - y * @height / @yRange
    @context.moveTo(0, yPos)
    @context.lineTo(@width, yPos)

    unless @params.get('xLabelPosition') is 'none'
      labelY = dashY = 0
      if @params.get('xLabelPosition') is 'bottom'
        labelY = yPos + 15
        dashY = yPos + 5
      else
        labelY = yPos - 15
        dashY = yPos - 5

      @context.textBaseline = 'middle'
      @context.textAlign = 'center'

      xRange = @maxRangeX()
      xMin = -@xOrigin * xRange / @width
      xMax = (@width - @xOrigin) * xRange / @width
      xStepSize = @roundStepSize(100 * xRange / @width)
      for x in [(xMin - xMin % xStepSize) .. xMax] by xStepSize
        if x <= (0 - xStepSize / 2) or (0 + xStepSize / 2) <= x
          xPos = @xOrigin + x * @width / xRange
          @context.moveTo(xPos, yPos)
          @context.lineTo(xPos, dashY)
          @context.fillText("#{@xAxisValueLabel(x, xStepSize)}", xPos, labelY)

    @context.save()
    xPos = if @xOrigin <= @width/2
      (@xOrigin + @width)/2
    else
      @xOrigin/2
    xPos = Math.round(xPos) if @context.pixelRatio is 1
    @context.translate(xPos, yPos + 15)
    MarkupText.render(@context, @xAxisLabel(), @defaultFont)
    @context.restore()

    @context.stroke()
    @context.closePath()

  renderYAxis: (x) ->
    @context.setLineDash []
    @context.font = @defaultFont
    @context.strokeStyle = "#999999"
    @context.fillStyle = "#000000"
    @context.lineWidth = 2

    @context.beginPath()
    xPos = @xOrigin + x * @width / @xRange
    @context.moveTo(xPos, 0)
    @context.lineTo(xPos, @height)

    unless @params.get('yLabelPosition') is 'none'
      labelX = dashX = 0
      if @params.get('yLabelPosition') is 'right'
        labelX = xPos + 10
        dashX = xPos + 5
        @context.textAlign = 'left'
      else
        labelX = xPos - 10
        dashX = xPos - 5
        @context.textAlign = 'right'
      @context.textBaseline = 'middle'

      yRange = @maxRangeY()
      yMin = -(@height - @yOrigin) * yRange / @height
      yMax = @yOrigin * yRange / @height
      yStepSize = @roundStepSize(100 * yRange / @height)
      for y in [(yMin - yMin % yStepSize) .. yMax] by yStepSize
        if y <= (0 - yStepSize / 2) or y >= (0 + yStepSize / 2)
          yPos = @yOrigin - y * @height / yRange
          @context.moveTo(xPos, yPos)
          @context.lineTo(dashX, yPos)
          @context.fillText(@yAxisValueLabel(y, yStepSize), labelX, yPos)

    @context.save();
    yPos = if @yOrigin < @height/2
      (@yOrigin + @height)/2
    else
      @yOrigin/2
    yPos = Math.round(yPos) if @context.pixelRatio is 1
    @context.translate(xPos - 15, yPos);
    @context.rotate(-Math.PI / 2);
    MarkupText.render(@context, @yAxisLabel(), @defaultFont)
    @context.restore()

    @context.stroke()
    @context.closePath()

  renderGrid: ->
    @context.strokeStyle = '#eeeeee'
    @context.lineWidth = 1
    @context.beginPath()

    unless @params.get('xLabelPosition') is 'none'
      xRange = @maxRangeX() unless xRange?
      xMin = -@xOrigin * xRange / @width
      xMax = (@width - @xOrigin) * xRange / @width
      xStepSize = @roundStepSize(100 * xRange / @width)
      for x in [(xMin - xMin % xStepSize) .. xMax] by xStepSize
        xPos = @xOrigin + x * @width / xRange
        @context.moveTo(xPos, 0)
        @context.lineTo(xPos, @height)

    unless @params.get('yLabelPosition') is 'none'
      yRange = @maxRangeY() unless yRange?
      yMin = -(@height - @yOrigin) * yRange / @height
      yMax = @yOrigin * yRange / @height
      yStepSize = @roundStepSize(100 * yRange / @height)
      for y in [(yMin - yMin % yStepSize) .. yMax] by yStepSize
        yPos = @yOrigin - y * @height / yRange
        @context.moveTo(0, yPos)
        @context.lineTo(@width, yPos)

    @context.stroke()
    @context.closePath()

  beforeRender: ->
    # Stub to execute code before rendering...

  render: =>
    @width = @params.get('width')
    @height = @params.get('height')
    @xOrigin = @params.get('xOrigin')
    @yOrigin = @params.get('yOrigin')
    @yOffset = @params.get('yOffset')
    @xRange = @params.get('xRange')
    @yRange = @params.get('yRange')

    @xMin = -@xOrigin * @xRange / @width
    @xMax = (@width - @xOrigin) * @xRange / @width

    @yMin = -(@height - @yOrigin) * @yRange / @height
    @yMax = @yOrigin * @yRange / @height

    return this if @width == null and @height == null

    @context ||= @el.getContext('2d')
    @context.clearRect(0, 0, @width, @height)

    @beforeRender()

    @renderGrid()
    xAxis = @params.get('xAxis')
    if $.isArray(xAxis.y)
      @renderXAxis(y) for y in xAxis.y
    else
      @renderXAxis(xAxis.y)
    yAxis = @params.get('yAxis')
    if $.isArray(yAxis.x)
      @renderYAxis(x) for x in yAxis.x
    else
      @renderYAxis(yAxis.x)
    @renderCurves()

    this
