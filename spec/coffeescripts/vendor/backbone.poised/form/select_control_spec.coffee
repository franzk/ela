describe 'Backbone.Poised.SelectControl', ->
  beforeEach ->
    @model = new Backbone.Model attr: 'foo'
    @view = new Backbone.Poised.SelectControl
      model: @model
      attribute: 'attr'
    $('#jasmine_content').html(@view.render().el)

  it 'should be extending Backbone.Poised.BaseControl', ->
    expect(@view).toBeInstanceOf(Backbone.Poised.BaseControl)

  describe 'Instantiation', ->
    it 'should require `model` option', ->
      expect => new Backbone.Poised.SelectControl()
      .toThrow new Error('Missing `model` option')
      expect => new Backbone.Poised.SelectControl(model: @model)
      .not.toThrow new Error('Missing `model` option')

    it 'should require `attribute` option', ->
      expect => new Backbone.Poised.SelectControl(model: @model)
      .toThrow new Error('Missing `attribute` option')
      expect => new Backbone.Poised.SelectControl(model: @model, attribute: 'attr')
      .not.toThrow new Error('Missing `attribute` option')

    it 'should only take allowed options', ->
      view = new Backbone.Poised.SelectControl
        model: @model
        attribute: 'attr'
        placeholder: 'Select now!'
        options: ['foo', 'bar']
        multiselect: true
        somethingElse: 'hö'
      expect(view.options.options).toEqual(['foo', 'bar'])
      expect(view.options.placeholder).toEqual('Select now!')
      expect(view.options.multiselect).toBeTruthy()
      expect(view.options.somethingElse).toBeUndefined()

  describe 'Element', ->
    it 'should have selectbox', ->
      expect(@view.el).toContainElement('.selectbox select')
