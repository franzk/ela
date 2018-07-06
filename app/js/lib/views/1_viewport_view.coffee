ELA.Views ?= {}

class ELA.Views.ViewportView extends Backbone.Poised.View
  className: 'view'

  render: =>
    @$el.empty()

    this
