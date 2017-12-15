describe 'Backbone.Poised.Textarea', ->
  beforeEach ->
    @model = new Backbone.Model(foo: 'Some text')
    @view = new Backbone.Poised.Textarea
      model: @model
      attribute: 'foo'
    $('#jasmine_content').html(@view.render().el)

  it 'should extend the Backbone.Poised.View', ->
    expect(@view).toBeInstanceOf(Backbone.Poised.View)

  describe 'Instantiations', ->
    it 'should require `model` option', ->
      expect => new Backbone.Poised.Textarea()
      .toThrow new Error('Missing `model` option')
      expect => new Backbone.Poised.Textarea(model: @model)
      .not.toThrow new Error('Missing `model` option')

    it 'should require `attribute` option', ->
      expect => new Backbone.Poised.Textarea(model: @model)
      .toThrow new Error('Missing `attribute` option')
      expect => new Backbone.Poised.Textarea(model: @model, attribute: 'foo')
      .not.toThrow new Error('Missing `attribute` option')

    it 'should take the `attribute` option', ->
      expect(@view.attribute).toEqual('foo')

    it 'should only take allowed options', ->
      view = new Backbone.Poised.Textarea
        model: @model
        attribute: 'foo'
        placeholder: 'Some placeholder ...'
        rows: 15
        somethingElse: 'ohai'
      expect(view.options.placeholder).toEqual('Some placeholder ...')
      expect(view.options.rows).toEqual(15)
      expect(view.options.somethingElse).toBeUndefined()

  describe 'Element', ->
    it 'should be a `span` tag', ->
      expect(@view.$el.is('span')).toBeTruthy()

    it 'should have `poised` class', ->
      expect(@view.$el).toHaveClass('poised')

    it 'should have `textarea` class', ->
      expect(@view.$el).toHaveClass('textarea')

    describe 'value', ->
      it 'should be rendered by default', ->
        expect(@view.$('textarea').val()).toEqual('Some text')

      it 'should be updated on model change', ->
        expect(@view.$('textarea').val()).toEqual('Some text')
        @model.set foo: 'Some longer text'
        expect(@view.$('textarea').val()).toEqual('Some longer text')

    describe 'on input', ->
      it 'should update the model attribute value', ->
        @view.$('textarea').val('New text').trigger('input')
        expect(@model.get('foo')).toEqual('New text')
