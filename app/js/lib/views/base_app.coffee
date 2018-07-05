ELA.Views ?= {}
class ELA.Views.BaseApp extends Backbone.Poised.View
  template: JST['general/app']
  headlineTemplate: JST['general/app_headline']

  id: -> @model.name.toDash()
  tagName: 'section'
  className: 'active'

  # Typically in a subclass we override the list of asides. This may
  # be a list of classes inheriting from ELA.Views.BaseAside or an
  # object with `name` and `klass` attributes.
  asides: [
    { name: 'parameters', view: 'ELA.Views.ParametersAside' }
  ]

  # Typically in a subclass we override the list of views.
  views: [ graph: {} ]

  events:
    'tap header .overview.icon': 'backToOverview'
    'tap header .help': 'showHelp'
    'tap header .share-link': 'share'
    'tap header .share-form input': 'selectShareLink'
    'tap header .share-form button': 'copyShareLink'
    'submit header .share-form form': (e) -> e.preventDefault()
    'tap header *[data-toggle-aside]': 'setCurrentAside'
    'tap header .poised.subviews.select': 'viewSubviewOptions'
    'tap header .poised.subviews.select .option.subapp': 'openSubapp'
    'tap header .poised.subviews.select .option.layout': 'openLayout'
    'tap header .context.icon': 'toggleContextMenu'
    'tap article.viewport:has(~ aside.active)': 'hideAsides'
    'tap article.viewport:has(~ .headup.active)': 'hideHeadup'
    'tap section:has(.subviews.select.view)': 'hideSubappOptions'
    'tap section:has(.menu.view)': 'hideMenus'

  hammerjs: true

  remove: =>
    @$el.afterTransitionForRemovingClass 'active', => super

  initialize: ->
    @listenTo @model, 'change:currentAside', @toggleAside
    @listenTo @model, 'change:showHelp', @renderHelp
    @on 'controlLiveChangeStart', @showHeadup
    @on 'controlLiveChangeEnd', @hideHeadup

    for aside in @asides
      aside.link ?= 'icon'

    @layouts ?=
      all:
        layout: _.map(@views, (view, idx) ->
          String.fromCharCode(97 + idx)
        )

    $(window).on('resize', @renderHeadlineHtml)
    $(window).on('resize', @checkLayout)
    @checkLayout()

    @model.displayParams ?= {}

  remove: ->
    super
    $(window).off('resize', @renderHeadlineHtml)
    $(window).off('resize', @checkLayout)

  checkLayout: =>
    availableLayouts = @availableLayouts()
    if availableLayouts.indexOf(@model.get('layout')) < 0
      ELA.router.navigate "app/#{@model.path}/#{availableLayouts[0]}",
        trigger: true

  viewSubviewOptions: =>
    @$('.subviews.select').toggleClass('view')

  hideSubviewOptions: =>
    @$('.subviews.select').removeClass('view')

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

  openLayout: (e) =>
    $target = $(e.target)
    ELA.router.navigate "app/#{@model.path}/#{$target.data('path')}",
      trigger: true

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
      _.compact(_.map(@asides, (aside) ->
        aside.name if aside.link is 'icon'
      ))

  contextAsides: ->
    @_contextAsideNames ?= do =>
      _.compact(_.map(@asides, (aside) =>
        if aside.link is 'contextMenu'
          name: aside.name
          label: @loadLocale("contextMenu.#{aside.name}")
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

  showHeadup: (control, options = {}) =>
    options.mobileOnly ?= true
    isMobile = $(window).width() <= 768
    if isMobile or not options.mobileOnly
      if isMobile
        @$('aside.active').addClass('hidden')
      else
        @model.set('currentAside', null)

      @subviews.headup.activate(control)

  hideHeadup: =>
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

  availableLayouts: ->
    names = []
    for name, layout of @layouts
      if layout.minWidth
        continue if layout.minWidth > $(window).width()
      if layout.minHeight
        continue if layout.minHeight > $(window).height()
      names.push(name)
    names

  headlineHtml: ->
    @headlineTemplate
      name: @model.name
      path: @model.path
      relatedApps: @relatedApps()
      availableLayouts: @availableLayouts()

  renderHeadlineHtml: =>
    @$('header h2').html(@headlineHtml())

  render: =>
    @$el.html @template
      hasHelpText: @model.hasHelpText
      iconAsideNames: @iconAsideNames()
      contextAsides: @contextAsides()
      views: view.name for view in @views
      currentPath: @model.path
      headlineHtml: @headlineHtml()
    @$shareLink = @$('li.share-link')
    @$shareForm = @$('li.share-form')
    @$shareUrlInput = @$shareForm.find('input')
    @$shareCopyButton = @$shareForm.find('button')

    _.delay(@renderHeadlineHtml)

    @$app = @$('section.app')
    for aside in @asides
      AsideView = aside.view.toFunction()
      view = @subviews[aside.name] = new AsideView
        model: @model
        parentView: this
        name: aside.name
        localePrefix: @localePrefix
      @$app.append(view.render().el)

    unless @subviews.headup?
      @$headup = @$('aside.headup')
      @subviews.headup = new ELA.Views.Headup
        el: @$headup
        localePrefix: @localePrefix

    unless @subviews.viewport
      view = @subviews.viewport = new ELA.Views.Viewport
        model: @model
        parentView: this
        views: @views
        layouts: @layouts
        localePrefix: @localePrefix
      @$('.viewport').replaceWith(view.render().el)

    @renderHelp()
    @toggleAside(@model, @model.get('currentAside'))

    this
