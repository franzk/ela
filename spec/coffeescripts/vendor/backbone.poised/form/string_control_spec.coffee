describe 'Backbone.Poised.StringControl', ->
  beforeEach ->
    @model = new Backbone.Model(attr: 'some text')
    @view = new Backbone.Poised.StringControl
      model: @model
      attribute: 'attr'
      rows: 1
    $('#jasmine_content').html(@view.render().el)

  it 'should be extending Backbone.Poised.BaseControl', ->
    expect(@view).toBeInstanceOf(Backbone.Poised.BaseControl)

  describe 'Instantiation', ->
    it 'should require `model` option', ->
      expect => new Backbone.Poised.StringControl()
      .toThrow new Error('Missing `model` option')
      expect => new Backbone.Poised.StringControl(model: @model)
      .not.toThrow new Error('Missing `model` option')

    it 'should require `attribute` option', ->
      expect => new Backbone.Poised.StringControl(model: @model)
      .toThrow new Error('Missing `attribute` option')
      expect => new Backbone.Poised.StringControl(model: @model, attribute: 'attr')
      .not.toThrow new Error('Missing `attribute` option')

    it 'should set `type` to text', ->
      view = new Backbone.Poised.StringControl
        model: @model, attribute: 'attr'
      expect(@view.options.type).toEqual('text')

    it 'should only take allowed options', ->
      view = new Backbone.Poised.StringControl
        model: @model
        attribute: 'attr'
        somethingElse: 'hö'
      expect(view.options.somethingElse).toBeUndefined()

  describe 'Element', ->
    describe 'with one row', ->
      it 'should have a `.textfield input`', ->
        expect(@view.el).toContainElement('.textfield input')

    describe 'with multiple rows', ->
      beforeEach ->
        @view = new Backbone.Poised.StringControl
          model: @model
          attribute: 'attr'
          rows: 4
        $('#jasmine_content').html(@view.render().el)

      it 'should have a `.textfield textarea`', ->
        expect(@view.el).toContainElement('.textarea textarea')
