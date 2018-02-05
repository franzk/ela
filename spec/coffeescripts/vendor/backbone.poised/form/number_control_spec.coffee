describe 'Backbone.Poised.NumberControl', ->
  beforeEach ->
    @model = new Backbone.Model numAttr: 10
    @view = new Backbone.Poised.NumberControl
      model: @model
      attribute: 'numAttr'
    $('#jasmine_content').html(@view.render().el)

  it 'should be extending Backbone.Poised.BaseControl', ->
    expect(@view).toBeInstanceOf(Backbone.Poised.BaseControl)

  describe 'Instantiation', ->
    it 'should require `model` option', ->
      expect => new Backbone.Poised.NumberControl()
      .toThrow new Error('Missing `model` option')
      expect => new Backbone.Poised.NumberControl(model: @model)
      .not.toThrow new Error('Missing `model` option')

    it 'should require `attribute` option', ->
      expect => new Backbone.Poised.NumberControl(model: @model)
      .toThrow new Error('Missing `attribute` option')
      expect => new Backbone.Poised.NumberControl(model: @model, attribute: 'fooBar')
      .not.toThrow new Error('Missing `attribute` option')

    it 'should set `type` to number', ->
      expect(@view.options.type).toEqual('number')

    it 'should only take allowed options', ->
      view = new Backbone.Poised.NumberControl
        model: @model
        attribute: 'numAttr'
        clearOnFocus: false
        stepSize: 5
        precision: 1
        range: [1, 10]
        unit: 'kg'
        somethingElse: 'hö'
      expect(view.options.clearOnFocus).toBeFalsy()
      expect(view.options.stepSize).toEqual(5)
      expect(view.options.precision).toEqual(1)
      expect(view.options.minValue).toEqual(1)
      expect(view.options.maxValue).toEqual(10)
      expect(view.options.unit).toEqual('kg')
      expect(view.options.somethingElse).toBeUndefined()

  describe 'Element', ->
    it 'should have spinner', ->
      expect(@view.el).toContainElement('.textfield')
