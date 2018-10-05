ELA.Views ?= {}
class ELA.Views.Graph extends ELA.Views.Canvas
  @Params: ELA.Models.GraphParams

  # A variable that contains temporary information about the pinch
  # or pan action that is currently performed.
  start: {}

  # Contains all view specific parameters that do not belong in the model.
  params: null

  # We need to cache current pixelRatio to reset the canvas scale.
  pixelRatio: null

  initialize: ->
    super

    @listenTo(@params,
      'change:xOrigin change:yOrigin ' +
      'change:yRange change:xRange ' +
      'change:width change:height ' +
      'change:axisLabelingForCurve'
      @requestRepaint
    )

    @listenTo(@model.curves, 'change:selected', @requestRepaint)
    @listenTo(@model, 'change:calculators', @requestRepaint)

    for guide in @params.get('guides')
      @listenTo(@model, "change:#{guide.attribute}", @requestRepaint)

  events:
    pan: 'pan'
    panstart: 'panstart'
    panend: 'panend'
    pinchstart: 'pinchstart'
    pinch: 'pinch'
    pinchend: 'pinchend'
    doubletap: 'resetCanvas'
    mousewheel: 'mousewheel'
    DOMMouseScroll: 'mousewheel'

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
    @params.reset()

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

  xAxisValueLabel: (val, stepsize) ->
    @axisLabel(val, stepsize)

  yAxisValueLabel: (val, stepsize) ->
    curve = @params.get('axisLabelingForCurve')
    if curve?
      curvePresenter = @Present(curve)
      val = curvePresenter.unitValue(val)
      stepsize = curvePresenter.unitValue(stepsize)
    @axisLabel(val - @params.get('yOffset'), stepsize)

  genericAxisLabel: (axis) ->
    axisLabel = @params.get("#{axis}AxisLabel")
    return axisLabel.call(this) if axisLabel? and _.isFunction(axisLabel)
    return axisLabel if axisLabel?

    axisLabelLocale = @params.get("#{axis}AxisLabelLocale")
    return @loadLocale(axisLabelLocale) if axisLabelLocale?

    curve = @params.get('axisLabelingForCurve')
    if curve?
      return @Present(curve).fullXAxisLabel() if axis is 'x'
      return @Present(curve).fullYAxisLabel() if axis is 'y'

    @loadLocale("graph.#{axis}AxisLabel", defaultValue: '')

  xAxisLabel: -> @genericAxisLabel('x')
  yAxisLabel: -> @genericAxisLabel('y')

  # Stubs
  beforeRenderCurves: ->
  afterRenderCurves: ->
  beforeRender: ->

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

      xRange = @params.maxRangeX()
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
    @context.translate(xPos, yPos + 8)
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

      yRange = @params.maxRangeY()
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
    @context.translate(xPos - 8 - 12, yPos);
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
      xRange = @params.maxRangeX() unless xRange?
      xMin = -@xOrigin * xRange / @width
      xMax = (@width - @xOrigin) * xRange / @width
      xStepSize = @roundStepSize(100 * xRange / @width)
      for x in [(xMin - xMin % xStepSize) .. xMax] by xStepSize
        xPos = @xOrigin + x * @width / xRange
        @context.moveTo(xPos, 0)
        @context.lineTo(xPos, @height)

    unless @params.get('yLabelPosition') is 'none'
      yRange = @params.maxRangeY() unless yRange?
      yMin = -(@height - @yOrigin) * yRange / @height
      yMax = @yOrigin * yRange / @height
      yStepSize = @roundStepSize(100 * yRange / @height)
      for y in [(yMin - yMin % yStepSize) .. yMax] by yStepSize
        yPos = @yOrigin - y * @height / yRange
        @context.moveTo(0, yPos)
        @context.lineTo(@width, yPos)

    @context.stroke()
    @context.closePath()

  getControlPoints: (x0, y0, x1, y1, x2, y2, tension) ->
    d01 = Math.sqrt(Math.pow(x1 - x0, 2) + Math.pow(y1 - y0, 2))
    d12 = Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2))
    fa = tension * d01 / (d01 + d12)
    fb = tension - fa
    p1x = x1 + fa * (x0 - x2)
    p1y = y1 + fa * (y0 - y2)
    p2x = x1 - fb * (x0 - x2)
    p2y = y1 - fb * (y0 - y2)
    [p1x, p1y, p2x, p2y]

  drawSpline: (points, t, closed, xPos = ((x) -> x), yPos = ((y) -> y)) ->
    if points.length <= 4
      @context.moveTo(xPos(points[0]), yPos(points[1]))
      @context.lineTo(xPos(points[2]), yPos(points[3]))
    else
      cp = []
      n = points.length
      points = _.clone(points)
      if closed
        points.push points[0], points[1], points[2], points[3]
        points.unshift points[n - 1]
        points.unshift points[n - 1]
        for i in [0..n] by 2
          cp = cp.concat(@getControlPoints(points[i], points[i+1], points[i+2], points[i+3], points[i+4], points[i+5], t))
        cp = cp.concat(cp[0], cp[1])
        for i in [0..n] by 2
          @context.moveTo(xPos(points[i]), yPos(points[i+1]))
          @context.bezierCurveTo(xPos(cp[2*i-2]), yPos(cp[2*i-1]), xPos(cp[2*i]), yPos(cp[2*i+1]), xPos(points[i+2]), yPos(points[i+3]))
      else
        for i in [0..(n-4)] by 2
          cp = cp.concat(@getControlPoints(points[i], points[i+1], points[i+2], points[i+3], points[i+4], points[i+5], t))

        @context.moveTo(xPos(points[0]), yPos(points[1]))
        @context.quadraticCurveTo(xPos(cp[0]), yPos(cp[1]), xPos(points[2]), yPos(points[3]))
        for i in [2..(n-3)] by 2
          @context.moveTo(xPos(points[i]), yPos(points[i+1]))
          @context.bezierCurveTo(xPos(cp[2*i-2]), yPos(cp[2*i-1]), xPos(cp[2*i]), yPos(cp[2*i+1]), xPos(points[i+2]), yPos(points[i+3]))
        @context.moveTo(xPos(points[n-2]), yPos(points[n-1]))
        @context.quadraticCurveTo(xPos(cp[2*n-10]), yPos(cp[2*n-9]), xPos(points[n-4]), yPos(points[n-3]))

  drawCurve: (points, tension = 0, closed = false, xPos = ((x) -> x), yPos = ((y) -> y)) ->
    if tension is 0
      beginning = true
      if points.length >= 2
        @context.moveTo(xPos(points[0]), yPos(points[1]))
        for i in [2...points.length] by 2
          @context.lineTo(xPos(points[i]), yPos(points[i+1]))
    else
      @drawSpline(points, tension, closed, xPos, yPos)

  renderCurves: ->
    resultCurves = []
    for calc, i in @model.get('calculators')
      for curve, j in @params.sortedCurves()
        func = curve.get('function')
        resultCurves.push
          curve: curve
          result: calc[func](@xMin, @xMax)
          yRange: @params.maxRangeY(func)
          xRange: @params.maxRangeX(func)
          calculatorIdx: i

    @beforeRenderCurves(resultCurves)

    for resultCurve in resultCurves
      curve = resultCurve.curve
      result = resultCurve.result
      yRange = resultCurve.yRange
      xRange = resultCurve.xRange
      if _.isObject(result)
        xPos = (x) => @xOrigin + x * @width / xRange
        yPos = (y) => @yOrigin - (y + @yOffset) * @height / yRange

        if curve.hasSubcurves()
          for name, subcurve of curve.subcurves()
            if result[name].points?
              @renderCurve(subcurve, result[name], xPos, yPos, resultCurve.calculatorIdx)
            else if result[name].radius?
              @renderCircle(subcurve, result[name], xPos, yPos, resultCurve.calculatorIdx)
        else
          if result.points?
            @renderCurve(curve, result, xPos, yPos, resultCurve.calculatorIdx)
          else if result.radius?
            @renderCircle(curve, result, xPos, yPos, resultCurve.calculatorIdx)

    @afterRenderCurves(resultCurves)

  renderCircle: (curve, result, xPos, yPos, calculatorIdx) ->
    func = curve.get('function')
    yRange = @maxRangeY(func)
    @context.beginPath()
    width  = Math.abs(xPos(2*result.radius) - @xOrigin)
    height = Math.abs(yPos(2*result.radius) - @yOrigin)
    centerX = xPos(result.center[0])
    centerY = yPos(result.center[1])

    aX = centerX - width/2
    aY = centerY - height/2
    hB = (width / 2) * .5522848
    vB = (height / 2) * .5522848
    eX = aX + width
    eY = aY + height
    mX = aX + width / 2
    mY = aY + height / 2
    @context.moveTo(aX, mY);
    @context.bezierCurveTo(aX, mY - vB, mX - hB, aY, mX, aY);
    @context.bezierCurveTo(mX + hB, aY, eX, mY - vB, eX, mY);
    @context.bezierCurveTo(eX, mY + vB, mX + hB, eY, mX, eY);
    @context.bezierCurveTo(mX - hB, eY, aX, mY + vB, aX, mY);

    @context.setLineDash(curve.lineDash(calculatorIdx))
    if curve.strokeStyle()
      @context.lineWidth = curve.get('lineWidth')
      @context.strokeStyle = curve.strokeStyle()
      @context.stroke()
    if fillStyle = curve.get('fillStyle')
      @context.fillStyle = fillStyle
      @context.fill()
    @context.closePath()

  renderCurve: (curve, result, xPos, yPos, calculatorIdx) ->
    @context.beginPath()
    @context.setLineDash(curve.lineDash(calculatorIdx))
    if result.multiplePaths
      for setOfPoints, i in result.points
        @drawCurve(setOfPoints, result.tension, false, xPos, yPos)
    else
      @drawCurve(result.points, result.tension, false, xPos, yPos)
    if curve.strokeStyle()
      @context.lineWidth = curve.get('lineWidth')
      @context.strokeStyle = curve.strokeStyle()
      @context.stroke()
    if fillStyle = curve.get('fillStyle')
      @context.fillStyle = fillStyle
      @context.fill()
    @context.closePath()

  renderGuide: (guide) ->
    valueAtPoint = @model.get(guide.attribute)

    @context.beginPath()
    @context.setLineDash []
    @context.strokeStyle = '#999999'
    @context.lineWidth = 2

    # Border below legend
    @context.moveTo(@width, 0)
    @context.lineTo(0, 0)

    if guide.orientation is 'vertical'
      # Border next to range handler
      @context.moveTo(0, @height)
      @context.lineTo(@width, @height)
      @context.lineTo(@width, @height-10)

      # Range handler line
      xPos = @xOrigin + valueAtPoint * @width / @xRange
      @context.moveTo(xPos, 0)
      @context.lineTo(xPos, @height)
    else
      # Border next to range handler
      @context.lineTo(0, @height)

      # Range handler line
      yPos = - valueAtPoint * @height / @yRange + @yOrigin
      @context.moveTo(0, yPos)
      @context.lineTo(@width, yPos)

    @context.stroke()
    @context.closePath()

    @context.beginPath()
    # The fillStyle of the triangle should match the color of the
    # background set for the legend and range handler in screen.styl:
    @context.fillStyle = "#f2f2f2"
    @context.lineWidth = 1

    if guide.orientation is 'vertical'
      @context.moveTo(xPos + 8, 0)
      @context.lineTo(xPos, 8)
      @context.lineTo(xPos - 8, 0)
      @context.moveTo(xPos - 8, @height)
      @context.lineTo(xPos, @height - 8)
      @context.lineTo(xPos + 8, @height)
    else
      @context.moveTo(0, yPos - 8)
      @context.lineTo(8, yPos)
      @context.lineTo(0, yPos + 8)
      @context.moveTo(@width, yPos - 8)
      @context.lineTo(@width - 8, yPos)
      @context.lineTo(@width, yPos + 8)
    @context.stroke()
    @context.fill()
    @context.closePath()

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
    
    for guide in @params.get('guides')
      @renderGuide(guide)

    this
