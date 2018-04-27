ELA.Models ?= {}
class ELA.Models.BaseApp extends ELA.Models.BaseAppModel
  hasHelpText: true

  initialize: (options = {}) ->
    @parentApp = options.parentApp

    @on 'change:path', @handlePath
    @set currentAside: @get('currentAside') or null
    @handlePath()

  handlePath: =>
    path = @get('path')

    @set(showHelp: _.last(path) is 'help')

    first = _.first(path)
    @set(layout: first) if first? and first isnt 'help'

  helpTextName: =>
    @path.replace('/', '_')

  # Initialize the curves attribute with all necessary options.
  #
  # @param [Array] curves curves to add to the curves collection
  # @param [Object] options reached through to collection initialization
  initCurves: (curves, options = {}) ->
    @curves = new ELA.Collections.Curves(curves, options)

  currentApp: -> this

  serialize: ->
    v = parameters: _.pick(
        @attributes
        _.keys(@defaults())
      )
    if @curves?
      v.selectedCurves = for curve in @curves.getHistory()
        curve.get('function')
    if @displayParams?
      v.displayParams = @displayParams.serialize()
    if @get('axisLabelingForCurve')?
      v.axisLabelingForCurve = @get('axisLabelingForCurve').get('function')
    v

  deserialize: (params) ->
    @set(params.parameters)

    for curve in @curves.models
      curve.set(selected: false)

    for curve in @curves.models
      curveFunction = curve.get('function')
      if _.contains(params.selectedCurves, curveFunction)
        curve.set(selected: true)
        if curveFunction is params.axisLabelingForCurve
          @set(axisLabelingForCurve: curve)

    # Wait until graphView has been created, it's initializer resets
    # displayParams
    if params.displayParams?
      _.defer =>
        @displayParams.deserialize(params.displayParams)
