ELA.Views ?= {}
class ELA.Views.BaseApp extends Backbone.Poised.View
  template: JST['general/app']

  id: -> @model.name.toDash()
  tagName: 'section'
  className: 'active'

  # Typically in a subclass we override the list of asides. This may
  # be a list of classes inheriting from ELA.Views.BaseAside or an
  # object with `name` and `klass` attributes.
  asides: []

  # Typically in a subclass we override the list of views.
  views: []

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
    @on 'controlLiveChangeStart', @liveChangeStart
    @on 'controlLiveChangeEnd', @liveChangeEnd

    for aside in @asides
      aside.link ?= 'icon'

    @model.displayParams ?= {}

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
      relatedApps: @relatedApps()
      currentPath: @model.path
    @$shareLink = @$('li.share-link')
    @$shareForm = @$('li.share-form')
    @$shareUrlInput = @$shareForm.find('input')
    @$shareCopyButton = @$shareForm.find('button')

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
        layout: @layout
        localePrefix: @localePrefix
      @$('.viewport').replaceWith(view.render().el)

    @renderHelp()
    @toggleAside(@model, @model.get('currentAside'))

    this
