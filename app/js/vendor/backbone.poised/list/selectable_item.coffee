class Backbone.Poised.List.SelectableItem extends Backbone.Poised.List.Item
  events: _.defaults {
    'change [type=checkbox]': 'updateModelSelection'
    'tap': 'updateModelSelection'
    'press': 'toggleSingleSelection'
  }, Backbone.Poised.List.Item.prototype.events

  selectedAttribute: 'selected'

  hammerjs:
    recognizers: [
      [Hammer.Rotate, { enable: false }],
      [Hammer.Pinch, { enable: false }, ['rotate']],
      [Hammer.Swipe, { enable: false }],
      [Hammer.Pan, { enable: false }, ['swipe']],
      [Hammer.Tap, { threshold: 5 }],
      [Hammer.Press]
    ]

  initialize: (options) ->
    super
    @options.singleSelect = options.singleSelect is true
    @model.on("change:#{@selectedAttribute}", @updateCheckboxState)

  updateCheckbox: =>
    @$checkbox.attr(checked: @model.get(@selectedAttribute))

  updateModelSelection: (e) =>
    @model.set(@selectedAttribute, not @model.get(@selectedAttribute))
    @model.collection.singleSelection = undefined
    @model.collection.selectedBeforeSingleSelection = undefined

  toggleSingleSelection: =>
    if @options.singleSelect
      collection = @model.collection
      if collection.singleSelection is @model
        collection.each (model) =>
          previousSelection = collection.selectedBeforeSingleSelection
          previouslySelected = previousSelection.indexOf(model) > -1
          model.set(@selectedAttribute, previouslySelected)
        collection.singleSelection = undefined
      else
        filter = {}
        filter[@selectedAttribute] = true
        collection.selectedBeforeSingleSelection ?= collection.where(filter)
        collection.singleSelection = @model
        collection.each (model) =>
          model.set(@selectedAttribute, model is @model)

  updateCheckboxState: =>
    @$checkbox.prop('checked', @model.get(@selectedAttribute))

  render: =>
    super

    @$checkbox = $ '<input>',
      type: 'checkbox'
      name: "model_#{@model.cid}"
    @updateCheckboxState()
    @$buttons.append(@$checkbox)
    @$buttons.append $ '<label>',
      for: "model_#{@model.cid}"
      class: 'checkbox'

    this
