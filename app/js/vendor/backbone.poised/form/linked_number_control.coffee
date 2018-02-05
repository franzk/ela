class Backbone.Poised.LinkedNumberControl extends Backbone.Poised.LinkedControl
  initialize: (options = {}) =>
    super

    @options = _.chain(options)
      .pick('clearOnFocus', 'stepSize', 'precision', 'range', 'attribute', 'unit', 'minValue', 'maxValue')
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

    @subviews.spinner1 = new Backbone.Poised.Textfield(_.defaults(model: @model1, @options))
    @$control1.append(@subviews.spinner1.render().el)
    @subviews.spinner2 = new Backbone.Poised.Textfield(_.defaults(model: @model2, @options))
    @$control2.append(@subviews.spinner2.render().el)

    this
