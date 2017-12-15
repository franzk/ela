class Backbone.Poised.LinkedStringControl extends Backbone.Poised.LinkedControl
  initialize: (options = {}) =>
    super

    @options = _.chain(options)
      .pick('attribute', 'rows', 'placeholder')
      .defaults
        type: 'text'
        placeholder: null
        rows: 1
      .value()

  render: =>
    super

    if @options.rows > 1
      @subviews.textarea1 = new Backbone.Poised.Textarea(_.defaults(model: @model1, @options))
      @$control1.append(@subviews.textarea1.render().el)
      @subviews.textarea2 = new Backbone.Poised.Textarea(_.defaults(model: @model2, @options))
      @$control2.append(@subviews.textarea2.render().el)
    else
      @subviews.textfield1 = new Backbone.Poised.Textfield(_.defaults(model: @model1, @options))
      @$control1.append(@subviews.textfield1.render().el)
      @subviews.textfield2 = new Backbone.Poised.Textfield(_.defaults(model: @model2, @options))
      @$control2.append(@subviews.textfield2.render().el)

    this
