ELA.Views ?= {}
class ELA.Views.Legend extends Backbone.Poised.View
  className: 'legend'

  valueCurveColumnTemplate: _.template '
<div class="values col<%= activeClass %>"
     data-index="<%= curveIndex %>"
     style="color: <%= strokeColor %>; <%= borderStyle %>">
  <div class="label"><%= label %></div>
</div>
'

  simpleCurveColumnTemplate: _.template '
<div class="curve">
  <div class="line" style="border-color: <%= strokeColor %>"></div>
  <%= label %>
</div>
'

  useValueAtRange: false

  initialize: (options) ->
    @displayParams = options.displayParams
    @listenTo(@displayParams, 'change:axisLabelingForCurve', @render)

    @listenTo @model, 'change:calculators', =>
      @bindCalculatorEvents()
      @render()

    @listenTo(@model.curves, 'change:selected', @render)

    @bindCalculatorEvents()

    @valueAttribute = options.valueAttribute if options.valueAttribute
    @_curves = options.curves

    if @valueAttribute
      @listenTo(@model, "change:#{@valueAttribute}", @render)

  events:
    'click .values.col': 'selectCurveForAxisLabeling'

  selectCurveForAxisLabeling: (e) ->
    index = parseInt($(e.currentTarget).data('index'))
    @displayParams.set(axisLabelingForCurve: @model.curves.at(index))

  bindCalculatorEvents: ->
    @stopListening(@model.previous('calculators'))
    for calc in @model.get('calculators')
      for curve in @curves()
        @listenTo(calc, "change:#{curve.get('function')}", @render)

  # Stub: Renders the header column.
  # Override in your custom Legend view.
  renderValueHeaderColumn: =>

  # Renders a simple curve column with values at range.
  # This renders the `#valueCurveColumnTemplate`.
  #
  # @param [ELA.Models.Curve] curve The curve to render
  renderValueCurveColumn: (curve) =>
    return unless curve.showInLegend()

    func = @calculatorFunction(curve)
    ref = @calcs[0]?[func]?(@range)
    isActive = curve is @labelingCurve
    $curve = $ @valueCurveColumnTemplate
      activeClass: if isActive then ' active' else ''
      curveIndex: @model.curves.indexOf(curve)
      strokeColor: curve.strokeStyle()
      borderStyle: "border-color: #{curve.strokeStyle()}" if isActive
      label: @Present(curve).fullLabel()

    for calc, i in @calcs
      val = calc[func](@range)
      if val?
        unitValue = @Present(curve).unitValue(val)
        if _.isArray(unitValue)
          unitValue = _.compact(unitValue)
          unitValue = _.map(unitValue, (v) -> v.toFixed(2))
          label = "{#{unitValue.join(', ')}}"
        else
          label = unitValue.toFixed(2)
        if ref and i > 0
          diff = (val / ref * 100) - 100
          label += " (#{diff.toFixed(2)}%)"
        $curve.append("<div>#{label}</div>")
      else
        $curve.append("<div>#{t('legend.notAvailable')}</div>")
    @$wrapper.append($curve)

  # Renders the simple curve column without values at range.
  # This renders the `#simpleCurveColumnTemplate`.
  #
  # @param [ELA.Models.Curve] curve The curve to render
  # @param [Number] curveIndex The index in the legends curve list
  renderSimpleCurveColumn: (curve, curveIndex) =>
    return unless curve.showInLegend()
    @$el.append $ @simpleCurveColumnTemplate
      strokeColor: curve.strokeStyle()
      label: @Present(curve).label()

  # Used to determine which function to display.
  # For interpolated Graphs you typically append `_value` to the curve
  # function.
  #
  # @param [Curve] curve The curve to find the calulator function for
  #
  # @return [String] The identifier of the calculator function
  calculatorFunction: (curve) ->
    "#{curve.get('function')}_value"

  curves: =>
    curves = @model.curves.whereInHistory()
    if @_curves
      _.filter curves, (curve) =>
        @_curves.indexOf(curve.get('function')) >= 0
    else
      curves

  render: =>
    if @valueAttribute
      @range = @model.get(@valueAttribute)
      if @range?
        @labelingCurve = @displayParams.get('axisLabelingForCurve')
        @calcs = @model.get('calculators')
        @$wrapper = $('<div class="values-at-range scroll-x">')

        @renderValueHeaderColumn()

        _.each(@curves(), @renderValueCurveColumn)

        # Replace keeping horizontal scroll position
        scrollLeft = @$el.find('.scroll-x').scrollLeft()
        @$el.html(@$wrapper)
        @$el.find('.scroll-x').scrollLeft(scrollLeft)
    else
      @$el.empty().addClass('legend-simple')
      _.each(@curves(), @renderSimpleCurveColumn)
    this
