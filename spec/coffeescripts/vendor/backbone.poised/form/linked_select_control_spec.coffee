describe 'Backbone.Poised.LinkedSelectControl', ->
  beforeEach ->
    @model1 = new Backbone.Model(attr: 10)
    @model2 = new Backbone.Model(attr: 10)
    @view = new Backbone.Poised.LinkedSelectControl
      model1: @model1
      model2: @model2
      attribute: 'attr'
    $('#jasmine_content').html(@view.render().el)

  it 'should be extending Backbone.Poised.LinkedControl', ->
    expect(@view).toBeInstanceOf(Backbone.Poised.LinkedControl)

  describe 'Instantiation', ->
    it 'should require `model1` option', ->
      expect => new Backbone.Poised.LinkedSelectControl()
      .toThrow new Error('Missing `model1` option')
      expect => new Backbone.Poised.LinkedSelectControl(model1: @model1)
      .not.toThrow new Error('Missing `model1` option')

    it 'should require `model2` option', ->
      expect => new Backbone.Poised.LinkedSelectControl(model1: @model1)
      .toThrow new Error('Missing `model2` option')
      expect => new Backbone.Poised.LinkedSelectControl(model1: @model1, model2: @model2)
      .not.toThrow new Error('Missing `model2` option')

    it 'should require an `attribute` option', ->
      expect => new Backbone.Poised.LinkedSelectControl(model1: @model1, model2: @model2)
      .toThrow new Error('Missing `attribute` option')
      expect => new Backbone.Poised.LinkedSelectControl(model1: @model1, model2: @model2, attribute: 'attr')
      .not.toThrow new Error('Missing `attribute` option')

    it 'should only take allowed options', ->
      view = new Backbone.Poised.LinkedSelectControl
        model1: @model1
        model2: @model2
        attribute: 'attr'
        placeholder: 'Some placeholder'
        options: ['foo']
        multiselect: true
        somethingElse: 'hö'
      expect(view.options.placeholder).toEqual('Some placeholder')
      expect(view.options.options).toEqual(['foo'])
      expect(view.options.multiselect).toEqual(true)
      expect(view.options.somethingElse).toBeUndefined()

  describe 'Element', ->
    it 'should have a selectbox for control 1', ->
      expect(@view.$('.first.control')).toContainElement('.selectbox select')

    it 'should have a selectbox for control 2', ->
      expect(@view.$('.second.control')).toContainElement('.selectbox select')
