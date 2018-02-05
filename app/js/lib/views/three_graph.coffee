ELA.Views ?= {}
class ELA.Views.ThreeGraph extends ELA.Views.Canvas
  class @Params extends Backbone.Model
    serializedAttributes: ['zoom']

    serialize: ->
      _.pick(@attributes, @serializedAttributes)

    deserialize: (attributes) ->
      @set(attributes)

  # A variable that contains temporary information about the pinch
  # or pan action that is currently performed.
  start: {}

  events:
    'pinchstart': 'pinchstart'
    'pinch': 'pinch'
    'pinchend': 'pinchend'
    'mousewheel': 'mousewheel'
    'DOMMouseScroll': 'mousewheel'
    'doubletap': 'resetCanvas'

  defaults:
    zoom: 1

  initialize: ->
    if Modernizr.webgl
      @renderer = new THREE.WebGLRenderer(canvas: @$el[0])
    else
      _.defer -> alert(t('messages.noWebGL'))
      @renderer = new THREE.CanvasRenderer(canvas: @$el[0])
    @renderer.setClearColor(0xffffff)

    @camera = new THREE.PerspectiveCamera(45, null, 100, 1000)
    @camera.position.z = 500

    @scene = new THREE.Scene()
    fog = new THREE.Fog(0xffffff, ELA.settings.laminateDeformation.graph.fogMinimumDistance, ELA.settings.laminateDeformation.graph.fogMaximumDistance)
    @scene.fog = fog

    super

    @params.on('change:zoom', @requestRepaint)

    new THREE.FontLoader().load(
      'ela/fonts/droid_sans_regular.typeface.svg'
      (font) =>
        @_droidSansRegularFont = font
        @trigger('threeJsFontLoaded')
    )

  setCanvasResolution: ->
    @renderer.setPixelRatio((window.devicePixelRatio || 1) * 2)

    width = @params.get('width')
    height = @params.get('height')

    @renderer.setSize(width, height)
    @camera.aspect = width / height
    @requestRepaint()

  mousewheel: (e) =>
    e.preventDefault()
    zoom = @params.get('zoom')
    if e.originalEvent.wheelDelta > 0 or e.originalEvent.detail < 0
      @params.set(zoom: zoom + 0.06)
    else
      return if zoom <= 0.06
      @params.set(zoom: zoom - 0.06)

  pinchstart: (e) =>
    @start.zoom = @params.get('zoom')

  pinch: (e) =>
    if @params.get('zoom') > 0.01 or scale > 1
      @params.set(zoom: @start.zoom * e.gesture.scale)

  pinchend: (e) =>
    # Do not call pan events on transformend
    @hammer.stop()

  resetCanvas: =>
    @params.set
      zoom: @defaults.zoom

  render: =>
    @camera.zoom = @params.get('zoom')
    @camera.updateProjectionMatrix()
    @renderer.render(@scene, @camera)

    this
