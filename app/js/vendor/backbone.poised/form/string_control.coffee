class Backbone.Poised.StringControl extends Backbone.Poised.BaseControl
  initialize: (options = {}) ->
    super

    @options = _.chain(options)
      .pick('model', 'attribute', 'rows', 'placeholder')
      .defaults
        type: 'text'
        placeholder: null
        rows: 1
      .value()

  render: =>
    super

    if @options.rows > 1
      @subviews.textarea = new Backbone.Poised.Textarea(@options)
      @$el.append(@subviews.textarea.render().el)
    else
      @subviews.textfield = new Backbone.Poised.Textfield(@options)
      @$input.html(@subviews.textfield.render().el)

    this
