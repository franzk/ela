class Backbone.Poised.RangeControl extends Backbone.Poised.BaseControl
  initialize: (options) =>
    super

    @options = _.chain(@options)
      .pick('model', 'renderSpinner', 'clearOnFocus', 'stepSize', 'precision', 'range', 'attribute', 'unit', 'sliderMinValue', 'sliderMaxValue', 'spinnerMinValue', 'spinnerMaxValue')
      .defaults
        renderSpinner: true
        clearOnFocus: true
        type: 'number'
      .value()

    if @options.stepSize? and not @options.precision?
      @options.precision = _.find([0..3], (i) =>
        @options.stepSize * Math.pow(10, i) >= 1)

    # A spinner field is a textfield of type number.
    if @options.renderSpinner
      @spinnerOptions = _.chain(@options)
        .pick('model', 'attribute', 'type', 'clearOnFocus', 'unit', 'precision', 'stepSize')
        .defaults
          minValue: _.firstDefined(@options.spinnerMinValue, @options.range?[0], @options.range?.spinner?[0])
          maxValue: _.firstDefined(@options.spinnerMaxValue, @options.range?[1], @options.range?.spinner?[1])
          parentView: this
        .value()

    @sliderOptions = _.chain(@options)
      .pick('model', 'attribute', 'stepSize')
      .defaults
        minValue: _.firstDefined(@options.sliderMinValue, @options.range?[0], @options.range?.slider?[0])
        maxValue: _.firstDefined(@options.sliderMaxValue, @options.range?[1], @options.range?.slider?[1])
        parentView: this
      .value()

  render: =>
    super

    if @options.renderSpinner
      @subviews.spinner = new Backbone.Poised.Textfield(@spinnerOptions)
      @$info.append(@subviews.spinner.render().el)
    else
      @subviews.value = new Backbone.Poised.Value(@options)
      @$info.append(@subviews.value.render().el)

    @subviews.slider = new Backbone.Poised.Slider(@sliderOptions)
    @$el.append(@subviews.slider.render().el)

    this
