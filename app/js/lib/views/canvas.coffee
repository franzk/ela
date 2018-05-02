ELA.Views ?= {}
class ELA.Views.Canvas extends Backbone.Poised.View
  @Params: ELA.Models.CanvasParams

  tagName: 'canvas'

  # True if an animation frame request is currently pending
  animationFrameRequested: false

  constructor: ->
    super
    fontWeight = if window.devicePixelRatio > 1 then 300 else 400
    @defaultFont = "#{fontWeight} 12px Roboto"

  initialize: (options = {}) ->
    # Make sure we got the parameters model for holding view specific
    # information
    @params = options.params

    @setCanvasResolution()

    $(window).on('resize', @readCanvasResolution)

    # If the legend uses the value at range feature, it's height
    # may change with updated calculators
    @listenTo(@model, 'change:calculators', @readCanvasResolution)

    @listenTo(@params, 'change:width change:height', @setCanvasResolution)

    @listenTo(@params, 'repaint', @requestRepaint)

  remove: ->
    super
    $(window).off('resize', @readCanvasResolution)

  readCanvasResolution: =>
    $parent = @$el.parent()
    # Do not take scale into account here, otherwise
    # non-active subapps will get initialized with wrong size
    # because they have a css scale of 0.75
    if $parent.length > 0
      @params.set
        width: $parent[0].clientWidth
        height: $parent[0].clientHeight

  setCanvasResolution: ->
    width = @params.get('width')
    height = @params.get('height')

    context = @el.getContext('2d')

    # Ratio between software dpi and device ppi.
    devicePixelRatio = window.devicePixelRatio || 1

    # On desktop computers the browser scales automatically.
    # This is deactivated on mobile devices due to memory.
    backingStoreRatio = context.webkitBackingStorePixelRatio ||
      context.mozBackingStorePixelRatio ||
      context.msBackingStorePixelRatio ||
      context.oBackingStorePixelRatio ||
      context.backingStorePixelRatio || 1

    context.pixelRatio = @pixelRatio = devicePixelRatio/backingStoreRatio

    @$el.css  width: width, height: height
    @$el.attr width: width * @pixelRatio, height: height * @pixelRatio

    context.scale(@pixelRatio, @pixelRatio)

  requestRepaint: =>
    unless @animationFrameRequested
      @animationFrameRequested = true
      requestAnimationFrame =>
        @animationFrameRequested = false
        @render()
