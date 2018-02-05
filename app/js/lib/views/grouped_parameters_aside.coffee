ELA.Views ?= {}
class ELA.Views.GroupedParametersAside extends ELA.Views.BaseAside
  render: =>
    @$el.addClass('scroll-y')
    subview = @subviews.form = new Backbone.Poised.Form
      model: @model
      liveForm: true
      parentView: this
      group:
        by: 'group'
      localePrefix: @model.localePrefix()
    @$el.html(subview.render().el)

    this
