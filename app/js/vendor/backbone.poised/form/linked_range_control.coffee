class Backbone.Poised.LinkedRangeControl extends Backbone.Poised.LinkedControl
  initialize: (options = {}) =>
    super

    @options = _.chain(options)
      .pick('renderSpinner', 'clearOnFocus', 'stepSize', 'precision', 'range', 'attribute', 'unit', 'sliderMinValue', 'sliderMaxValue', 'spinnerMinValue', 'spinnerMaxValue')
      .defaults
        renderSpinner: true
        clearOnFocus: true
        stepSize: 1
        precision: _.find([0..3], (i) ->
          options.stepSize * Math.pow(10, i) >= 1)
        type: 'number'
      .value()

    # A spinner field is a textfield of type number.
    if @options.renderSpinner
      @spinnerOptions = _.chain(@options)
        .pick('attribute', 'type', 'clearOnFocus', 'unit', 'precision', 'stepSize')
        .defaults
          minValue: _.firstDefined(@options.spinnerMinValue, @options.range?[0], @options.range?.spinner?[0])
          maxValue: _.firstDefined(@options.spinnerMaxValue, @options.range?[1], @options.range?.spinner?[1])
          parentView: this
        .value()

    @sliderOptions = _.chain(@options)
      .pick('attribute', 'stepSize')
      .defaults
        minValue: _.firstDefined(@options.sliderMinValue, @options.range?[0], @options.range?.slider?[0])
        maxValue: _.firstDefined(@options.sliderMaxValue, @options.range?[1], @options.range?.slider?[1])
        parentView: this
      .value()

  render: =>
    super

    if @options.renderSpinner
      @subviews.spinner1 = new Backbone.Poised.Textfield(_.defaults(model: @model1, @spinnerOptions))
      @$control1.append(@subviews.spinner1.render().el)
      @subviews.spinner2 = new Backbone.Poised.Textfield(_.defaults(model: @model2, @spinnerOptions))
      @$control2.append(@subviews.spinner2.render().el)
    else
      @subviews.value1 = new Backbone.Poised.Value(_.defaults(model: @model1, @options))
      @$control1.append(@subviews.value1.render().el)
      @subviews.value2 = new Backbone.Poised.Value(_.defaults(model: @model2, @options))
      @$control2.append(@subviews.value2.render().el)

    @subviews.slider1 = new Backbone.Poised.Slider(_.defaults(model: @model1, @spinnerOptions))
    @$control1.append(@subviews.slider1.render().el)
    @subviews.slider2 = new Backbone.Poised.Slider(_.defaults(model: @model2, @spinnerOptions))
    @$control2.append(@subviews.slider2.render().el)

    this
