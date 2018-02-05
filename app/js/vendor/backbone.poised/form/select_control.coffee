class Backbone.Poised.SelectControl extends Backbone.Poised.BaseControl
  initialize: (options = {}) ->
    super

    @options = _.chain(options)
      .pick('model', 'attribute', 'placeholder', 'options', 'multiselect', 'locale', 'localePrefix')
      .defaults(parentView: this)
      .value()

  render: =>
    super

    @subviews.selectbox = new Backbone.Poised.Selectbox(@options)
    @$info.append(@subviews.selectbox.render().el)

    this
