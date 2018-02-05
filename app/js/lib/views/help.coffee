ELA.Views ?= {}
class ELA.Views.Help extends Backbone.View
  id: 'help'
  tagName: 'section'

  template: JST['general/help']
  typeset: false
  scrollTarget: null

  events:
    'tap header .back.icon': 'goBack'
    'tap header h2': 'scrollToToc'
    'click a': 'scrollToAnchor'

  hammerjs: true

  goBack: (e) =>
    if @model.path?
      ELA.router.navigate("app/#{@model.path}", trigger: true)
    else
      ELA.router.navigate('/', trigger: true)

  scrollToAnchor: (e) =>
    href = $(e.currentTarget).attr('href')
    if href.match /^#(.*)$/
      $target = @$article.find(href)
      if $target.length > 0
        e.preventDefault()
        @scrollTo href
        @scrollTarget = href

  remove: =>
    @$el.afterTransitionForRemovingClass 'active', =>
      super

  scrollToToc: (e) =>
    @scrollTo '.toc'
    e.stopPropagation()

  setActive: (val) ->
    @$el.toggleClass('active', val)

  activate: ->
    @$el.toggleClass('active', true)

  deactivate: ->
    @$el.toggleClass('active', false)

  scrollTo: (target) =>
    @$article.scrollTo target, 600,
      axis: 'y'
      offset: -5

  renderMath: =>
    # MathJax may not have been loaded yet
    typesetCallback = =>
      @$el.find('.toast').addClass('hidden')
      @scrollTo @scrollTarget if @scrollTarget?
    performTypeset = =>
      if window.MathJax.isReady
        MathJax.Hub.Queue(["Typeset", MathJax.Hub, @$article[0], typesetCallback]);
      else
        setTimeout performTypeset, 100
    performTypeset()

  renderArticle: (text) =>
    unless ELA.converter
      ELA.converter = new Markdown.Converter()
      Markdown.Extra.init(ELA.converter)
    @$article.html(ELA.converter.makeHtml(text))
    Markdown.Toc.apply(@$article)
    @renderMath()

  render: =>
    @$el.html(@template())
    @$article = @$el.find('article')
    unless @loadingOrLoadedSuccessfully
      @loadingOrLoadedSuccessfully = true
      fileName = @model.helpTextName?() or 'about'
      $.ajax "help/#{fileName}.md",
        success: @renderArticle
        error: =>
          @loadingOrLoadedSuccessfully = false
          @$el.find('.toast').addClass('hidden')
          @$article.html(t('help.messages.missing_help_text'))
    this
