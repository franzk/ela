ELA.Models ?= {}
class ELA.Models.Curve extends Backbone.Model
  defaults:
    selected: false
    lineDash: null
    lineWidth: 3
    zIndex: 0
    group: 'general'
  parentCurve: null

  # https://jsfiddle.net/wct4bctb/
  LINE_DASHES: [
    [],
    [6, 4],                          # 10
    [2, 2],                          # 4
    [2, 4, 10, 4],                   # 20
    [2, 4, 2, 4, 2, 4, 2, 4, 10, 4], # 38
    [26, 6],                         # 32
    [2, 4, 26, 4]                    # 36
    [2, 4, 2, 4, 2, 4, 2, 4, 26, 4]  # 54
  ]

  initialize: (attributes, options = {}) ->
    super

    # We have to reinitialize the subcurves every time. Otherwise they
    # stay as Curve objects in the Model (Beware the scope of the
    # subcurves reference, its class wide).
    subcurves = {}
    for name, subcurve of (attributes.subcurves or {})
      subcurves[name] = new ELA.Models.Curve(subcurve, parentCurve: this)
    @set('subcurves', subcurves)
    @parentCurve = options.parentCurve if options.parentCurve?

  showInLegend: ->
    show = @get('showInLegend')
    if show? then show else true

  strokeStyle: ->
    if @get('strokeStyle')?
      @get('strokeStyle')
    else if @parentCurve?
      @parentCurve.strokeStyle()
    else
      index = @collection.filter((c) -> c.attributes.strokeStyle is undefined).indexOf(this)
      length = @collection.length
      saturation = Math.round(65 - 40 * ((index % 20) / 20))
      luminance = Math.round(65 - 15 * ((index % 20) / 20 + 1))
      distance = 360 * 0.61088
      hue = index * distance
      'hsl(' + hue + ",#{saturation}%,#{luminance}%)"

  # @return Array canvas lineDash definition
  lineDash: (idx = 0) ->
    @get('lineDash') or @LINE_DASHES[idx % @LINE_DASHES.length]

  hasSubcurves: ->
    _.keys(@subcurves()).length > 0

  subcurves: ->
    @get('subcurves')

  subcurve: (key) ->
    @get('subcurves')[key]

  select: => @set(selected: true)
  deselect: => @set(selected: false)

  toJSON: =>
    _.defaults super(),
      strokeStyle: @strokeStyle()
      hsl: @strokeStyle()

  Presenter: class Presenter extends Backbone.Poised.View
    unitValue: (value) ->
      unitFn = @model.get('unitFn')
      return unitFn(value) if _.isFunction(unitFn)

      unitFactor = @model.get('unitFactor')
      return unitFactor * value if unitFactor?

      value

    # Returns the label.
    #
    # @return String The label
    label: ->
      @_label ||= do =>
        func = @model.get('function')
        @loadLocale "curves.#{func}.label", "curves.#{func}.yAxisLabel", "curves.#{func}.xAxisLabel",
          'curves.yAxisLabel', 'curves.xAxisLabel',
          defaultValue: func.toLabel()

    # Returns the x-axis label.
    #
    # @return String The label for the x-axis
    xAxisLabel: ->
      @_xAxisLabel ||= do =>
        func = @model.get('function')
        @loadLocale "curves.#{func}.xAxisLabel", 'curves.xAxisLabel',
          defaultValue: func.toLabel()

    # Returns the y-axis label.
    #
    # @return String The label for the y-axis
    yAxisLabel: ->
      @_yAxisLabel ||= do =>
        func = @model.get('function')
        @loadLocale "curves.#{func}.yAxisLabel", 'curves.yAxisLabel',
          defaultValue: func.toLabel()

    # Returns the y axis unit label.
    #
    # With the introduction of distinction between curve specific x
    # and y axis labeling, this function is deprecated in favor of
    # `#xAxisUnitLabel` and `#yAxisUnitLabel`.
    #
    # @deprecated
    #
    # @return String The unit for the y-axis
    unitLabel: ->
      console.log('ELA.Models.Curve.Presenter#unitLabel is deprecated.')
      unit = @model.get('unit')
      if unit then "[#{unit}]" else ''

    # Returns the x-axis unit label.
    #
    # @return String The unit for the x-axis
    xAxisUnitLabel: ->
      @_xAxisUnitLabel ||= do =>
        func = @model.get('function')
        @loadLocale "curves.#{func}.xAxisUnitLabel", 'curves.xAxisUnitLabel',
          returnNull: true

    # Returns the y axis unit label.
    #
    # @return String The unit for the y-axis
    yAxisUnitLabel: ->
      @_yAxisUnitLabel ||= do =>
        func = @model.get('function')
        @loadLocale "curves.#{func}.yAxisUnitLabel", 'curves.yAxisUnitLabel',
          returnNull: true

    # Returns the full label as concatenation of `#label` and
    # `#unitLabel`. Generally used for curve specific axis labling.
    #
    # With the introduction of distinction between curve specific x
    # and y axis labeling, this function is deprecated in favor of
    # `#fullXAxisLabel` and `#fullYAxisLabel`.
    #
    # @deprecated
    #
    # @return String The full curve label
    fullLabel: ->
      console.log('ELA.Models.Curve.Presenter#fullLabel is deprecated.')
      "#{@label()} #{@unitLabel()}"

    # Returns the full label for the x-axis as concatenation of label
    # and unit label.
    #
    # @return String The full label for the x-axis
    fullXAxisLabel: ->
      unit = @xAxisUnitLabel()
      unit = if unit? then " [#{unit}]" else ''
      "#{@xAxisLabel()}#{unit}"

    # Returns the full label for the y-axis as concatenation of label
    # and unit label.
    #
    # @return String The full label for the y-axis
    fullYAxisLabel: ->
      unit = @yAxisUnitLabel()
      unit = if unit? then " [#{unit}]" else ''
      "#{@yAxisLabel()}#{unit}"

    subcurveLabel: (subcurve) ->
      func = @model.get('function')
      @loadLocale "curves.#{func}.subcurves.#{subcurve}.label",
        defaultValue: func
