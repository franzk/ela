ELA.Views ?= {}
class ELA.Views.Headup extends Backbone.Poised.View
  activate: (control) =>
    # Clone the control view to add a new DOM element showing the same values
    @subviews.control = control.clone()
    @$el.addClass('active')
    @render()

  deactivate: =>
    @$el.removeClass('active')
    @subviews.control?.remove()

  render: =>
    @$el.html(@subviews.control.render().el)
    this
