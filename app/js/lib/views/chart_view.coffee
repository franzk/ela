ELA.Views ?= {}

class ELA.Views.ChartView extends ELA.Views.ViewportView
  initialize: (options = {}) ->
    unless options.name?
      throw 'ELA.Views.GraphView: option `name` is required'

    if options.chart?.view
      @ChartView = options.chart.view.toFunction()
    else
      @ChartView = ELA.Views.ChartJS
    @displayParams = @model.displayParams[options.name] = new @ChartView.Params

    @chartConfig = $.extend(true, {}, options.chart?.config)
    @chartDataFunction = options.chart?.dataFunction or 'data'

    @subviews = {}

  render: =>
    $chart = $('<div>', class: 'chart')
    view = @subviews.chart ?= new @ChartView
      model: @model
      parentView: this
      localePrefix: @localePrefix
      params: @displayParams
      dataFunction: @chartDataFunction
      config: @chartConfig

    $chart.html(view.render().el)
    @$el.html($chart)
    this
