ELA.Views ?= {}
class ELA.Views.BaseApp extends Backbone.Poised.View
  template: JST['general/app']

  id: -> @model.name.toDash()
  tagName: 'section'
  className: 'active'

  # Typically in a subclass we override the list of asides. This may
  # be a list of classes inheriting from ELA.Views.BaseAside or an
  # object with `name` and `klass` attributes.
  asideViews: []

  legendView: null

  graphView: null
  graphOverlayView: null
  graphDefaults: {}

  rangeHandlerView: null

  # TODO: Rename valueAtRange name pattern to something like selectValue
  # TODO: use correct attribute in every app instead of generic valueAtRange
  valueAtRange: null
  valueAtRangeAxis: 'x'
  valueAtRangeAttribute: 'valueAtRange'
  valueAtRangePrecision: null

  legendValueAtRange: null
  legendValueAtRangeAxis: null
  legendValueAtRangeAttribute: null

  useHeadup: false

  events:
    'tap header .overview.icon': 'backToOverview'
    'tap header .help': 'showHelp'
    'tap header .share-link': 'share'
    'tap header .share-form input': 'selectShareLink'
    'tap header .share-form button': 'copyShareLink'
    'submit header .share-form form': (e) -> e.preventDefault()
    'tap header *[data-toggle-aside]': 'setCurrentAside'
    'tap header .poised.subapps.select': 'viewSubappOptions'
    'tap header .poised.subapps.select .option': 'openSubapp'
    'tap header .context.icon': 'toggleContextMenu'
    'tap article.graph:has(~ aside.active)': 'hideAsides'
    'tap section:has(.subapps.select.view)': 'hideSubappOptions'
    'tap section:has(.menu.view)': 'hideMenus'

  hammerjs: true

  remove: =>
    @$el.afterTransitionForRemovingClass 'active', => super

  initialize: ->
    @listenTo @model, 'change:currentAside', @toggleAside
    @listenTo @model, 'change:showHelp', @renderHelp
    if @useHeadup
      @on 'controlLiveChangeStart', @liveChangeStart
      @on 'controlLiveChangeEnd', @liveChangeEnd

    for asideView in @asideViews
      asideView.link ?= 'icon'

    if @graphView?
      GraphParams = @graphView.toFunction()['Params']
      @model.displayParams = new GraphParams if GraphParams?

  viewSubappOptions: =>
    @$('.subapps.select').toggleClass('view')

  hideSubappOptions: =>
    @$('.subapps.select').removeClass('view')

  toggleContextMenu: =>
    @$('.menu:has(.icon.context)').toggleClass('view')

  hideMenus: (e) =>
    unless e? and $(e.target).closest(@$shareLink.add(@$shareForm)).length
      @$('.menu').removeClass('view')
      @$shareForm.addClass('hidden')
      @$shareCopyButton.removeClass('success failure').addClass('copy')
      @$shareLink.removeClass('hidden')

  openSubapp: (e) =>
    $target = $(e.target)
    ELA.router.navigate("app/#{$target.data('path')}", trigger: true)

  showHelp: =>
    ELA.router.navigate("app/#{@model.path}/help", trigger: true)

  share: =>
    @$shareUrlInput.val(ELA.app.url())
    @$shareLink.addClass('hidden')
    @$shareForm.removeClass('hidden')

  selectShareLink: =>
    @$shareUrlInput.select()

  copyShareLink: =>
    @selectShareLink()
    if document.execCommand('copy')
      @$shareCopyButton.removeClass('copy').addClass('success')
    else
      @$shareCopyButton.removeClass('copy').addClass('failure')

  setCurrentAside: (e) =>
    asideToToggle = $(e.currentTarget).data('toggle-aside')
    currentAside = @model.get('currentAside')
    if currentAside is asideToToggle
      @model.set currentAside: null
    else
      @model.set currentAside: asideToToggle

  hideAsides: =>
    @model.set currentAside: null

  iconAsideNames: ->
    @_iconAsideNames ?= do =>
      _.compact(_.map(@asideViews, (asideView) ->
        asideView.name if asideView.link is 'icon'
      ))

  contextAsides: ->
    @_contextAsideNames ?= do =>
      _.compact(_.map(@asideViews, (asideView) =>
        if asideView.link is 'contextMenu'
          name: asideView.name
          label: @loadLocale("contextMenu.#{asideView.name}")
      ))

  backToOverview: =>
    ELA.router.navigate('/', trigger: true)

  toggleAside: (model, value) =>
    previous = model.previousAttributes().currentAside
    if previous?
      @$("header .#{previous}.aside.icon").toggleClass('active', false)
      @$("aside.#{previous}").toggleClass('active', false)
    if value?
      @$("header .#{value}.aside.icon").toggleClass('active', true)
      @$("aside.#{value}").toggleClass('active', true)

  liveChangeStart: (slider) =>
    if $(window).width() <= 768
      @$('aside.active').addClass('hidden')
      @subviews.headup.activate(slider)

  liveChangeEnd: =>
    if $(window).width() <= 768
      @$('aside.active').removeClass('hidden')
      @subviews.headup.deactivate()

  setActive: (active) =>
    @$el.toggleClass('active', active)

  activate: =>
    @$el.toggleClass('active', true)

  deactivate: =>
    @$el.toggleClass('active', false)

  relatedApps: =>
    @model.parentApp?.subappInfo() or []

  renderHelp: =>
    showHelp = @model.get('showHelp')
    if showHelp and not @subviews.help?
      @subviews.help = view = new ELA.Views.Help
        model: @model
      @$el.append(view.render().el)

    delay =>
      @subviews.help?.setActive(showHelp)
      @$app.toggleClass('active', not showHelp)

  render: =>
    @$el.html @template
      name: @model.name
      path: @model.path
      hasHelpText: @model.hasHelpText
      iconAsideNames: @iconAsideNames()
      contextAsides: @contextAsides()
      legendView: @legendView?
      graphOverlayView: @graphOverlayView?
      graphView: @graphView?
      rangeHandlerView: @rangeHandlerView?
      useHeadup: @useHeadup
      relatedApps: @relatedApps()
      currentPath: @model.path
    @$shareLink = @$('li.share-link')
    @$shareForm = @$('li.share-form')
    @$shareUrlInput = @$shareForm.find('input')
    @$shareCopyButton = @$shareForm.find('button')

    @$app = @$('section.app')
    for aside in @asideViews
      AsideView = aside.view.toFunction()
      view = @subviews[aside.name] = new AsideView
        model: @model
        parentView: this
        name: aside.name
        localePrefix: @localePrefix
      @$app.append(view.render().el)

    if @legendView? and not @subviews.legend
      @$legend = @$('article .legend')
      LegendView = @legendView.toFunction()
      @subviews.legend = view = new LegendView
        model: @model
        parentView: this
        el: @$legend
        useValueAtRange: @legendValueAtRange or @valueAtRange or @rangeHandlerView?
        valueAtRangeAxis: @legendValueAtRangeAxis or @valueAtRangeAxis
        valueAtRangeAttribute: @legendValueAtRangeAttribute or @valueAtRangeAttribute
        localePrefix: @localePrefix
      view.render()

    if @graphOverlayView? and not @subviews.graphOverlayView
      @$graphOverlay = @$('article .graph-overlay')
      GraphOverlayView = @graphOverlayView.toFunction()
      @subviews.graphOverlayView = view = new GraphOverlayView
        model: @model
        parentView: this
        el: @$graphOverlay
        localPrefix: @localePrefix
      view.render()

    if @rangeHandlerView? and not @subviews.rangeHandler?
      @$rangeHandler = @$('article .range-handler')
      RangeHandlerView = @rangeHandlerView.toFunction()
      @subviews.rangeHandler = view = new RangeHandlerView
        model: @model
        parentView: this
        el: @$rangeHandler
        axis: @valueAtRangeAxis
        attribute: @valueAtRangeAttribute
        precision: @valueAtRangePrecision
        localePrefix: @localePrefix
      view.render()

    if @useHeadup and not @subviews.headup?
      @$headup = @$('aside.headup')
      @subviews.headup = new ELA.Views.Headup
        el: @$headup
        localePrefix: @localePrefix

    delay =>
      if @graphView? and not @subviews.graph
        @$graph = @$('article .graph')
        GraphView = @graphView.toFunction()
        @subviews.graph = view = new GraphView
          model: @model
          parentView: this
          params: @model.displayParams
          defaults: _.defaults
            # Taken from ELA.Views.Canvas::readCanvasResolution
            width: @$graph[0].clientWidth
            height: @$graph[0].clientHeight
            valueAtRangeAxis: @valueAtRangeAxis
            valueAtRangeAttribute: @valueAtRangeAttribute
          , @graphDefaults
          localePrefix: @localePrefix
        @$graph.html(view.render().el)

        # If the legend uses the value at range feature, it's height
        # may change with updated calculators
        if @subviews.legend?.useValueAtRange
          @listenTo(@model, 'change:calculators', view.readCanvasResolution)

    @renderHelp()
    @toggleAside(@model, @model.get('currentAside'))

    this
