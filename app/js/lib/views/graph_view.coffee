ELA.Views ?= {}

class ELA.Views.GraphView extends ELA.Views.ViewportView
  className: "#{ELA.Views.ViewportView::className} graph-view"

  initialize: (options = {}) ->
    unless options.name?
      throw 'ELA.Views.GraphView: option `name` is required'

    unless options.legend is false
      if _.isObject(options.legend) and options.legend.view?
        @LegendView = options.legend.view.toFunction()
        @legendValueAttribute = options.legend.valueAttribute
      else
        @LegendView = ELA.Views.Legend
      @legendValueAttribute ?= options.graph?.axes?.x?.attribute

    if options.graphOverlay?.view?
      @GraphOverlayView = options.graphOverlay.view.toFunction()

    if options.graph?.axes?
      if options.graph.axes.x?
        @xAxisY = options.graph.axes.x.y
        @xAxisScale = options.graph.axes.x.scale
      if options.graph.axes.y?
        @yAxisX = options.graph.axes.y.x
        @yAxisScale = options.graph.axes.y.scale

    for axis, props of options.graph?.axes
      if props.handler
        switch axis
          when 'x' then @bottomAxisHandler = attribute: props.attribute
          when 'y' then @leftAxisHandler = attribute: props.attribute
    @guides = []
    if @bottomAxisHandler?
      @guides.push
        orientation: 'vertical'
        attribute: @bottomAxisHandler.attribute
    if @leftAxisHandler?
      @guides.push
        orientation: 'horizontal'
        attribute: @leftAxisHandler.attribute

    if options.graph?.curves?
      @curves = options.graph.curves.slice()
      @axisLabelingForCurve = @model.curves.find (curve) =>
        curve.get('function') is @curves[0]
    else
      @axisLabelingForCurve = @model.curves.first()

    if options.graph?.view
      @GraphView = options.graph.view.toFunction()
    else
      @GraphView = ELA.Views.Graph
    @displayParams = @model.displayParams[options.name] ?= new @GraphView.Params
      guides: @guides
      curves: @curves
      axisLabelingForCurve: @axisLabelingForCurve
      xAxisY: @xAxisY
      xAxisScale: @xAxisScale
      yAxisX: @yAxisX
      yAxisScale: @yAxisScale
      app: @model
      xOrigin: options.graph?.xOrigin
      yOrigin: options.graph?.yOrigin
      xScale: options.graph?.xScale
      yScale: options.graph?.yScale
      xOriginRatio: options.graph?.xOriginRatio
      yOriginRatio: options.graph?.yOriginRatio

    @subviews = {}

  render: =>
    super

    if @LegendView?
      view = @subviews.legend ?= new @LegendView
        model: @model
        parentView: this
        localePrefix: @localePrefix
        valueAttribute: @legendValueAttribute
        curves: @curves
        displayParams: @displayParams
      @$el.append(view.render().el)

    if @GraphOverlayView?
      view = @subviews.graphOverlay ?= new @GraphOverlayView
        model: @model
        parentView: this
        localePrefix: @localePrefix
      @$el.append(view.render().el)

    $horizontalWrapper = $('<div>', class: 'horizontal-wrapper')

    if @leftAxisHandler?
      view = @subviews.leftAxisHandler ?= new ELA.Views.AxisHandler
        model: @model
        displayParams: @displayParams
        attribute: @leftAxisHandler.attribute
        position: 'left'
        parentView: this
        localePrefix: @localePrefix
      $horizontalWrapper.append(view.render().el)

    $graph = $('<div>', class: 'graph')
    $a = $('<a>', id: 'upstream', href: ELA.settings.upstream.url, target: '_blank')
    $a.html($('<img>', src: 'images/logo.png'))
    $horizontalWrapper.append($graph.html($a))
    @$el.append($horizontalWrapper)

    if @bottomAxisHandler?
      view = @subviews.bottomAxisHandler ?= new ELA.Views.AxisHandler
        model: @model
        displayParams: @displayParams
        attribute: @bottomAxisHandler.attribute
        position: 'bottom'
        parentView: this
        localePrefix: @localePrefix
      @$el.append(view.render().el)

    delay =>
      @subviews.graph?.remove()
      # Taken from ELA.Views.Canvas::readCanvasResolution
      @displayParams.set
        width: $graph[0].clientWidth
        height: $graph[0].clientHeight
      view = @subviews.graph = new @GraphView
        model: @model
        parentView: this
        params: @displayParams
        localePrefix: @localePrefix
      if @leftAxisHandler?
        view.$el.on 'tap', (e) =>
          unless @subviews.bottomAxisHandler?.hasRecentlyOpenInput()
            @subviews.leftAxisHandler.handleTap(e)
      if @bottomAxisHandler?
        view.$el.on 'tap', (e) =>
          unless @subviews.leftAxisHandler?.hasRecentlyOpenInput()
            @subviews.bottomAxisHandler.handleTap(e)
      $graph.append(view.render().el)

    this
