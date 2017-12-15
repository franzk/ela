describe 'Backbone.Poised.RangeControl', ->
  beforeEach ->
    @model = new Backbone.Model numAttr: 10
    @view = new Backbone.Poised.RangeControl
      model: @model
      attribute: 'numAttr'
    $('#jasmine_content').html(@view.render().el)

  it 'should be extending Backbone.Poised.BaseControl', ->
    expect(@view).toBeInstanceOf(Backbone.Poised.BaseControl)

  describe 'Instantiation', ->
    it 'should require `model` option', ->
      expect => new Backbone.Poised.RangeControl()
      .toThrow new Error('Missing `model` option')
      expect => new Backbone.Poised.RangeControl(model: @model)
      .not.toThrow new Error('Missing `model` option')

    it 'should require `attribute` option', ->
      expect => new Backbone.Poised.RangeControl(model: @model)
      .toThrow new Error('Missing `attribute` option')
      expect => new Backbone.Poised.RangeControl(model: @model, attribute: 'fooBar')
      .not.toThrow new Error('Missing `attribute` option')

    it 'should only take allowed options', ->
      view = new Backbone.Poised.RangeControl
        model: @model
        attribute: 'numAttr'
        renderSpinner: false
        clearOnFocus: false
        stepSize: 5
        precision: 1
        range:
          slider: [1, 10]
          spinner: [1, 10]
        unit: 'kg'
        somethingElse: 'hö'
      expect(view.options.renderSpinner).toBeFalsy()
      expect(view.options.clearOnFocus).toBeFalsy()
      expect(view.options.stepSize).toEqual(5)
      expect(view.options.precision).toEqual(1)
      expect(view.options.unit).toEqual('kg')
      expect(view.options.somethingElse).toBeUndefined()

    it 'should default `type` option to `number`', ->
      expect(@view.options.type).toEqual('number')

    it 'should set correct boundaries, if separate min/max values are given', ->
      view = new Backbone.Poised.RangeControl
        model: @model
        attribute: 'numAttr'
        sliderMinValue: 1
        sliderMaxValue: 10
        spinnerMinValue: -15
        spinnerMaxValue: 15
      expect(view.sliderOptions.minValue).toEqual(1)
      expect(view.sliderOptions.maxValue).toEqual(10)
      expect(view.spinnerOptions.minValue).toEqual(-15)
      expect(view.spinnerOptions.maxValue).toEqual(15)

    it 'should set correct boundaries, if range object is given', ->
      view = new Backbone.Poised.RangeControl
        model: @model
        attribute: 'numAttr'
        range:
          slider: [1, 10]
          spinner: [-15, 15]
      expect(view.sliderOptions.minValue).toEqual(1)
      expect(view.sliderOptions.maxValue).toEqual(10)
      expect(view.spinnerOptions.minValue).toEqual(-15)
      expect(view.spinnerOptions.maxValue).toEqual(15)

    it 'should set correct boundaries, if range array is given', ->
      view = new Backbone.Poised.RangeControl
        model: @model
        attribute: 'numAttr'
        range: [1, 10]
      expect(view.sliderOptions.minValue).toEqual(1)
      expect(view.sliderOptions.maxValue).toEqual(10)
      expect(view.spinnerOptions.minValue).toEqual(1)
      expect(view.spinnerOptions.maxValue).toEqual(10)

  describe 'Event Handler', ->
    it 'should receive events from Slider', ->
      liveChangeStart = jasmine.createSpy('liveChangeStart')
      @view.on('liveChangeStart', liveChangeStart)
      @view.subviews.slider.trigger('liveChangeStart')
      expect(liveChangeStart).toHaveBeenCalled()
