describe 'Backbone.Poised.Value', ->
  beforeEach ->
    @model = new Backbone.Model(foo: 10)
    @view = new Backbone.Poised.Value
      model: @model
      attribute: 'foo'
    $('#jasmine_content').html(@view.render().el)

  it 'should extend the Backbone.Poised.View', ->
    expect(@view).toBeInstanceOf(Backbone.Poised.View)

  describe 'Instantiations', ->
    it 'should require `model` option', ->
      expect => new Backbone.Poised.Value()
      .toThrow new Error('Missing `model` option')
      expect => new Backbone.Poised.Value(model: @model)
      .not.toThrow new Error('Missing `model` option')

    it 'should require `attribute` option', ->
      expect => new Backbone.Poised.Value(model: @model)
      .toThrow new Error('Missing `attribute` option')
      expect => new Backbone.Poised.Value(model: @model, attribute: 'foo')
      .not.toThrow new Error('Missing `attribute` option')

    it 'should take the `attribute` option', ->
      expect(@view.attribute).toEqual('foo')

  describe 'Element', ->
    it 'should be a `span` tag', ->
      expect(@view.$el.is('span')).toBeTruthy()

    it 'should have `poised` class', ->
      expect(@view.$el).toHaveClass('poised')

    it 'should have `value` class', ->
      expect(@view.$el).toHaveClass('value')

    describe 'content', ->
      it 'should be rendered by default', ->
        expect(@view.$el).toHaveHtml('10')

      it 'should be updated on model change', ->
        expect(@view.$el).toHaveHtml('10')
        @model.set foo: 20
        expect(@view.$el).toHaveHtml('20')
