ELA.Views ?= {}
class ELA.Views.Overview extends Backbone.Poised.View
  id: 'overview'
  tagName: 'section'
  className: 'active'

  template: JST['overview/app']

  events:
    'tap header .help.icon': 'showHelp'

  hammerjs: true

  keep: true

  initialize: ->
    $(window).resize @adjustDimensions

    # Split the apps into their respective groups for easy grouping in
    # Poised.List.
    apps = _.chain(ELA.settings.apps)
      .sortBy (app) ->
        app.name
      .map (app) ->
        groups = ELA.settings[app].groups
        if groups? and groups.length > 0
          for group in groups
            name: app
            group: group
        else
          name: app
      .flatten()
      .value()

    @collection = new Backbone.Collection(apps)

  setActive: (val) ->
    @$el.toggleClass('active', val)

  activate: =>
    @$el.toggleClass('active', true)

  deactivate: =>
    @$el.toggleClass('active', false)

  showHelp: =>
    ELA.router.navigate('about', trigger: true)

  calculateTileSize: =>
    # ul has 14px padding
    width = @$el.width() - 2 * 14

    # Stylus variables
    tileSize = 200

    columns = Math.ceil(width / tileSize)
    Math.floor(Math.min(width / columns, tileSize))

  adjustDimensions: =>
    size = @calculateTileSize()
    @$('.tile').each (i, elem) ->
      $(elem).css
        height: "#{size}px"
        width: "#{size}px"

  render: ->
    @$el.html(@template())

    if /Android.*Chrome/.test(navigator.userAgent)
      @$('#chrome-android-flag-hint').css display: 'block'

    @list = new Backbone.Poised.List
      filterAttributes: []
      collection: @collection
      itemClass: ELA.Views.OverviewTile
      group:
        by: 'group'
        sorting: ELA.settings.appGroups
        collapsible: true
      localePrefix: 'overview'
    @$('article ul').replaceWith(@list.render().el)

    delay @adjustDimensions

    this
