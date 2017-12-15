class Backbone.Poised.LinkedSelectControl extends Backbone.Poised.LinkedControl
  initialize: (options = {}) =>
    super

    @options = _.chain(options)
      .pick('attribute', 'placeholder', 'options', 'multiselect', 'locale', 'localePrefix')
      .defaults(parentView: this)
      .value()

  render: =>
    super

    @subviews.spinner1 = new Backbone.Poised.Selectbox(_.defaults(model: @model1, @options))
    @$control1.append(@subviews.spinner1.render().el)
    @subviews.spinner2 = new Backbone.Poised.Selectbox(_.defaults(model: @model2, @options))
    @$control2.append(@subviews.spinner2.render().el)

    this
