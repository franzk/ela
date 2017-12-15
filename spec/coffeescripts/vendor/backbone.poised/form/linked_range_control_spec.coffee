describe 'Backbone.Poised.LinkedRangeControl', ->
  beforeEach ->
    @model1 = new Backbone.Model(attr: 10)
    @model2 = new Backbone.Model(attr: 10)
    @view = new Backbone.Poised.LinkedRangeControl
      model1: @model1
      model2: @model2
      attribute: 'attr'
    $('#jasmine_content').html(@view.render().el)

  it 'should be extending Backbone.Poised.LinkedControl', ->
    expect(@view).toBeInstanceOf(Backbone.Poised.LinkedControl)

  describe 'Instantiation', ->
    it 'should require `model1` option', ->
      expect => new Backbone.Poised.LinkedRangeControl()
      .toThrow new Error('Missing `model1` option')
      expect => new Backbone.Poised.LinkedRangeControl(model1: @model1)
      .not.toThrow new Error('Missing `model1` option')

    it 'should require `model2` option', ->
      expect => new Backbone.Poised.LinkedRangeControl(model1: @model1)
      .toThrow new Error('Missing `model2` option')
      expect => new Backbone.Poised.LinkedRangeControl(model1: @model1, model2: @model2)
      .not.toThrow new Error('Missing `model2` option')

    it 'should require an `attribute` option', ->
      expect => new Backbone.Poised.LinkedRangeControl(model1: @model1, model2: @model2)
      .toThrow new Error('Missing `attribute` option')
      expect => new Backbone.Poised.LinkedRangeControl(model1: @model1, model2: @model2, attribute: 'attr')
      .not.toThrow new Error('Missing `attribute` option')

    it 'should only take allowed options', ->
      view = new Backbone.Poised.LinkedRangeControl
        model1: @model1
        model2: @model2
        attribute: 'attr'
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
      view = new Backbone.Poised.LinkedRangeControl
        model1: @model1
        model2: @model2
        attribute: 'attr'
        sliderMinValue: 1
        sliderMaxValue: 10
        spinnerMinValue: -15
        spinnerMaxValue: 15
      expect(view.sliderOptions.minValue).toEqual(1)
      expect(view.sliderOptions.maxValue).toEqual(10)
      expect(view.spinnerOptions.minValue).toEqual(-15)
      expect(view.spinnerOptions.maxValue).toEqual(15)

    it 'should set correct boundaries, if range object is given', ->
      view = new Backbone.Poised.LinkedRangeControl
        model1: @model1
        model2: @model2
        attribute: 'attr'
        range:
          slider: [1, 10]
          spinner: [-15, 15]
      expect(view.sliderOptions.minValue).toEqual(1)
      expect(view.sliderOptions.maxValue).toEqual(10)
      expect(view.spinnerOptions.minValue).toEqual(-15)
      expect(view.spinnerOptions.maxValue).toEqual(15)

    it 'should set correct boundaries, if range array is given', ->
      view = new Backbone.Poised.LinkedRangeControl
        model1: @model1
        model2: @model2
        attribute: 'attr'
        range: [1, 10]
      expect(view.sliderOptions.minValue).toEqual(1)
      expect(view.sliderOptions.maxValue).toEqual(10)
      expect(view.spinnerOptions.minValue).toEqual(1)
      expect(view.spinnerOptions.maxValue).toEqual(10)

  describe 'Event Handler', ->
    it 'should receive events from slider 1', ->
      liveChangeStart = jasmine.createSpy('liveChangeStart')
      @view.on('liveChangeStart', liveChangeStart)
      @view.subviews.slider1.trigger('liveChangeStart')
      expect(liveChangeStart).toHaveBeenCalled()

    it 'should receive events from slider 2', ->
      liveChangeStart = jasmine.createSpy('liveChangeStart')
      @view.on('liveChangeStart', liveChangeStart)
      @view.subviews.slider2.trigger('liveChangeStart')
      expect(liveChangeStart).toHaveBeenCalled()
