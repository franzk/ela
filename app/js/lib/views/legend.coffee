ELA.Views ?= {}
class ELA.Views.Legend extends Backbone.Poised.View
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
    @model.on 'change:axisLabelingForCurve', @render
    @model.curves.on 'change:selected', =>
      @bindCalculatorEvents()
      @render()
    @model.on 'change:calculators', =>
      @bindCalculatorEvents()
      @render()
    @bindCalculatorEvents()
    @useValueAtRange = options.useValueAtRange
    @valueAtRangeAxis = options.valueAtRangeAxis or 'x'
    @valueAtRangeAttribute = options.valueAtRangeAttribute or 'valueAtRange'

    @model.on "change:#{@valueAtRangeAttribute}", @render

  events:
    'click .values.col': 'selectCurveForAxisLabeling'

  selectCurveForAxisLabeling: (e) ->
    index = parseInt($(e.currentTarget).data('index'))
    @model.set
      axisLabelingForCurve: @model.curves.at(index)

  bindCalculatorEvents: ->
    @stopListening()
    for calc in @model.get('calculators')
      for curve in @model.curves.models
        @listenTo calc, "change:#{curve.get('function')}", @render

  # Stub: Renders the header column.
  # Override in your custom Legend view.
  renderValueHeaderColumn: =>

  # Returns the curves axis label according to the value of
  # `@valueAtRangeAxis`.
  #
  # @return String The label for the specific axis.
  curveLabel: (curve) =>
    switch @valueAtRangeAxis
      when 'x' then @Present(curve).fullYAxisLabel()
      when 'y' then @Present(curve).fullXAxisLabel()

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
      label: @curveLabel(curve)

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
      label: @Present(curve).fullLabel()

  # Used to determine which function to display.
  # For interpolated Graphs you typically append `_value` to the curve
  # function.
  #
  # @param [Curve] curve The curve to find the calulator function for
  #
  # @return [String] The identifier of the calculator function
  calculatorFunction: (curve) ->
    "#{curve.get('function')}_value"

  render: =>
    if @useValueAtRange
      @range = @model.get(@valueAtRangeAttribute)
      if @range?
        @labelingCurve = @model.get('axisLabelingForCurve')
        @calcs = @model.get('calculators')
        @$wrapper = $('<div class="values-at-range scroll-x">')

        @renderValueHeaderColumn()

        _.each @model.curves.whereInHistory(), @renderValueCurveColumn

        # Replace keeping horizontal scroll position
        scrollLeft = @$el.find('.scroll-x').scrollLeft()
        @$el.html(@$wrapper)
        @$el.find('.scroll-x').scrollLeft(scrollLeft)
      this
    else
      @$el.empty().addClass('legend-simple')
      _.each @model.curves.whereInHistory(), @renderSimpleCurveColumn
      this
