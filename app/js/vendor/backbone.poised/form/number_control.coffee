class Backbone.Poised.NumberControl extends Backbone.Poised.BaseControl
  initialize: (options = {}) ->
    super

    @options = _.chain(options)
      .pick('model', 'clearOnFocus', 'stepSize', 'precision', 'range', 'attribute', 'unit', 'minValue', 'maxValue')
      .defaults
        clearOnFocus: true
        type: 'number'
        minValue: _.firstDefined(options.minValue, options.range?[0])
        maxValue: _.firstDefined(options.maxValue, options.range?[1])
        parentView: this
      .value()

    if @options.stepSize? and not @options.precision?
      @options.precision = _.find([0..3], (i) =>
        @options.stepSize * Math.pow(10, i) >= 1)

  render: =>
    super

    @subviews.spinner = new Backbone.Poised.Textfield(@options)
    @$info.append(@subviews.spinner.render().el)

    this
