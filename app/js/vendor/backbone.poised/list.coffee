Backbone.Poised ||= {}
class Backbone.Poised.List extends Backbone.Poised.View
  tagName: 'ul'
  className: 'poised'

  addButtonTemplate: _.template("<li class='add button'><%= label %></li>")

  extractGroupOptions: (options = {}) ->
    @options.group = _.chain(options)
      .pick('by', 'collapsible', 'collapsed', 'sorting')
      .defaults
        collapsible: false
        collapsed: []
      .value()

  initialize: (options) ->
    @options = _.chain(options)
      .pick('filterAttributes', 'itemClass', 'itemLabel', 'itemTemplate', 'addible', 'addLabel', 'singleSelect')
      .defaults
        filterAttributes: false
        itemClass: Backbone.Poised.List.Item
        addible: false
        singleSelect: false
      .value()

    @extractGroupOptions(options.group)

    @collection.on 'add remove reset', @render

  appendSearchfield: =>
    @subviews.searchfield = new Backbone.Poised.List.Searchfield
      parentView: this
      locale: @locale
      localePrefix: @localePrefix
    @$el.append(@subviews.searchfield.render().el)

  appendItem: (model, $el = @$el) =>
    @subviews["item#{model.cid}"] = itemView = new @options.itemClass
      model: model
      parentView: this
      itemLabel: @options.itemLabel
      itemTemplate: @options.itemTemplate
      filterAttributes: @options.filterAttributes
      singleSelect: @options.singleSelect
      locale: @locale
      localePrefix: @localePrefix
    $el.append(itemView.render().el)

  appendAddButton: =>
    @subviews.addButton = new Backbone.Poised.List.AddButton
      label: (@options.addLabel or 'Add item')
      parentView: this
      locale: @locale
      localePrefix: @localePrefix
    @$el.append(@subviews.addButton.render().el)

  appendGroup: (group, models) =>
    group = group.toCamel()
    @subviews[group] = groupView = new Backbone.Poised.List.Anchor
      name: group
      parentView: this
      collapsible: $.ematch(group, @options.group.collapsible)
      collapsed: $.ematch(group, @options.group.collapsed)
      locale: @locale
      localePrefix: @localePrefix

    @$el.append(groupView.render().el)

    $grp = $('<ul>', class: 'poised list-group')

    @$el.append($grp)
    @appendItem(model, $grp) for model in models

  render: =>
    @$el.html('')

    @appendSearchfield() if @options.filterAttributes
    @appendAddButton() if @options.addible

    if @options.group.by
      groupedModels = @collection.groupBy(@options.group.by)
      groups = if _.isFunction(@options.group.sorting)
        _.chain(groupedModels)
          .keys()
          .sort(@options.group.sorting)
          .value()
      else
        @options.group.sorting or _.keys(groupedModels)

      for group in groups
        models = groupedModels[group]
        @appendGroup(group, models) if models?
    else
      @collection.each (model) =>
        @appendItem(model)

    this
