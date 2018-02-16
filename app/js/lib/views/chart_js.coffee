ELA.Views ?= {}

class ELA.Views.ChartJS extends Backbone.Poised.View
  class @Params extends Backbone.Model

  tagName: 'canvas'

  initialize: (options = {}) ->
    @chartConfig = $.extend(true, {}, options.config)
    if @chartConfig.options?.title?
      $.extend @chartConfig.options.title,
        fontFamily: 'Roboto'
        fontStyle: '500'
    $.extend @chartConfig.options,
      maintainAspectRatio: false
    @dataFunction = options.dataFunction
    @params = options.params

    @listenTo(@model.get('calculators')[0], "change:#{@dataFunction}", @render)

  render: =>
    if @chart
      @chart.data = @model.get('calculators')[0][@dataFunction]()
      @chart.update(duration: 0)
    else
      options = $.extend true, {}, @chartConfig
      options.data = @model.get('calculators')[0][@dataFunction]()
      @chart = new Chart(@el.getContext('2d'), options)
    this
