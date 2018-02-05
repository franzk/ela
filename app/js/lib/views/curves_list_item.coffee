ELA.Views ?= {}
class ELA.Views.CurvesListItem extends Backbone.Poised.List.SelectableItem
  labelParameters: ->
    label: @Present(@model).label()

  initialize: ->
    super
    @model.on("change:#{@selectedAttribute}", @render)
