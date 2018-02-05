ELA.Views ?= {}
class ELA.Views.CurveGraph extends ELA.Views.BaseGraph
  initialize: (options = {}) ->
    super

    @bindCalculatorEvents()

    @model.curves.on 'change:selected', =>
      @bindCalculatorEvents()
      @requestRepaint()

    @model.on 'change:calculators', =>
      @calculateRanges()
      @bindCalculatorEvents()
      @requestRepaint()

    @model.on 'change:valueAtRange', @requestRepaint
    @model.on 'change:axisLabelingForCurve', @requestRepaint

  bindCalculatorEvents: ->
    # Remove current callbacks, add new ones for each curve
    @stopListening(@model.previous('calculators'))

    for calc in @model.get('calculators')
      for curve in @model.curves.history
        @listenTo calc, "change:#{curve.get('function')}", @requestRepaint

      @listenTo calc, 'change:maxX change:maxY', @calculateRanges
      # TODO: Add dynamic dependencies to calculator, so that we can
      # actually only listen to maxY changes and recalculate ranges.
      oldestCurve = @model.curves.history[0]
      if oldestCurve?
        @listenTo calc, "change:#{oldestCurve.get('function')}", @calculateRanges

  calculateRanges: =>
    @params.set xRange: @maxRangeX()

  maxRangeX: =>
    max = _.chain(@model.get('calculators'))
      .map (c) -> c.maxX()
      .max()
      .value()
    min = _.chain(@model.get('calculators'))
      .map (c) -> c.minX()
      .min()
      .value()
    range = 0
    range += max if max > 0
    range -= min if min < 0
    (Math.abs(range) or 10000) * @params.get('xScale') * 1.1

  maxRangeY: (func) =>
    unless func?
      func = @model.get('axisLabelingForCurve')?.get('function')
    max = _.chain(@model.get('calculators'))
      .map (c) -> c.maxY(func, c.minX(), c.maxX(), 30)
      .max()
      .value()
    min = _.chain(@model.get('calculators'))
      .map (c) -> c.minY(func, c.minX(), c.maxX(), 30)
      .min()
      .value()
    range = 0
    range += max if max > 0
    range -= min if min < 0
    Math.abs(range) * @params.get('yScale') * 1.1

  xAxisValueLabel: (val, stepsize) ->
    @axisLabel(val, stepsize)

  yAxisValueLabel: (val, stepsize) ->
    curve = @model.get('axisLabelingForCurve')
    val = @Present(curve).unitValue(val) if curve?
    @axisLabel(val, stepsize)

  yAxisLabel: ->
    curve = @model.get('axisLabelingForCurve')
    @Present(curve).fullYAxisLabel()

  renderCurves: ->
    for calc, i in @model.get('calculators')
      for curve, j in @model.curves.history
        func = curve.get('function')

        @context.strokeStyle = curve.strokeStyle()
        @context.lineWidth = 3
        if i == 1
          @context.setLineDash [4,5]
        else
          @context.setLineDash []
        xPos = 0
        brokenLine = 1
        plotted = 0
        @context.beginPath()
        xPos = 0
        yRange = @maxRangeY(func)
        yMin = -(@height - @yOrigin) * yRange / @height
        yMax = @yOrigin * yRange / @height
        for xPos in [-2 .. (@width + 3)]
          x = @xMin + xPos * @xRange / @width
          val = calc[func](x)
          y = val
          if y?
            yPos = (yMax - y) * @height / yRange
            if brokenLine > 0
              @context.moveTo(xPos, yPos) if brokenLine == 1
              brokenLine -= 1
            else
              @context.lineTo(xPos, yPos)
              plotted += 1

        @context.stroke()
        @context.closePath()

  renderRangeIndicator: ->
    @context.setLineDash []
    @context.beginPath()
    @context.strokeStyle = '#999999'
    @context.lineWidth = 2
    @context.moveTo(0, 0)
    @context.lineTo(@width, 0)
    @context.stroke()

    @context.beginPath()
    @context.strokeStyle = '#999999'
    @context.lineWidth = 2
    @context.moveTo(0, @height)
    @context.lineTo(@width, @height)
    @context.stroke()

    if @model.get('valueAtRange')?
      valueAtPoint = @model.get('valueAtRange')

      @context.beginPath()
      @context.strokeStyle = '#999999'
      @context.lineWidth = 2
      xPos = @xOrigin + valueAtPoint * @width / @xRange
      @context.moveTo(xPos, 0)
      @context.lineTo(xPos, @height)
      @context.stroke()
      @context.closePath()

      @context.beginPath()
      @context.lineWidth = 1

      # The fillStyle of the triangle should match the color of the
      # legend background set in screen.styl:
      @context.fillStyle = "#f2f2f2"

      @context.moveTo(xPos + 8, 0)
      @context.lineTo(xPos, 8)
      @context.lineTo(xPos - 8, 0)
      @context.moveTo(xPos - 8, @height)
      @context.lineTo(xPos, @height - 8)
      @context.lineTo(xPos + 8, @height)
      @context.stroke()
      @context.fill()
      @context.closePath()

  render: =>
    super
    @renderRangeIndicator()
    this
