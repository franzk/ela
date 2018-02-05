describe 'Backbone.Poised.LinkedStringControl', ->
  beforeEach ->
    @model1 = new Backbone.Model(attr: 'Some String')
    @model2 = new Backbone.Model(attr: 'Some String')
    @view = new Backbone.Poised.LinkedStringControl
      model1: @model1
      model2: @model2
      attribute: 'attr'
    $('#jasmine_content').html(@view.render().el)

  it 'should be extending Backbone.Poised.LinkedControl', ->
    expect(@view).toBeInstanceOf(Backbone.Poised.LinkedControl)

  describe 'Instantiation', ->
    it 'should require `model1` option', ->
      expect => new Backbone.Poised.LinkedStringControl()
      .toThrow new Error('Missing `model1` option')
      expect => new Backbone.Poised.LinkedStringControl(model1: @model1)
      .not.toThrow new Error('Missing `model1` option')

    it 'should require `model2` option', ->
      expect => new Backbone.Poised.LinkedStringControl(model1: @model1)
      .toThrow new Error('Missing `model2` option')
      expect => new Backbone.Poised.LinkedStringControl(model1: @model1, model2: @model2)
      .not.toThrow new Error('Missing `model2` option')

    it 'should require an `attribute` option', ->
      expect => new Backbone.Poised.LinkedStringControl(model1: @model1, model2: @model2)
      .toThrow new Error('Missing `attribute` option')
      expect => new Backbone.Poised.LinkedStringControl(model1: @model1, model2: @model2, attribute: 'attr')
      .not.toThrow new Error('Missing `attribute` option')

    it 'should set `type` to text', ->
      view = new Backbone.Poised.LinkedStringControl
        model1: @model1
        model2: @model2
        attribute: 'attr'
      expect(@view.options.type).toEqual('text')

    it 'should only take allowed options', ->
      view = new Backbone.Poised.LinkedStringControl
        model1: @model1
        model2: @model2
        attribute: 'attr'
        somethingElse: 'hö'
      expect(view.options.somethingElse).toBeUndefined()

  describe 'Element', ->
    describe 'with one row', ->
      it 'should have a textfield for control 1', ->
        expect(@view.$('.first.control')).toContainElement('.textfield input')

      it 'should have a textfield for control 2', ->
        expect(@view.$('.second.control')).toContainElement('.textfield input')

    describe 'with more than one row', ->
      beforeEach ->
        @view = new Backbone.Poised.LinkedStringControl
          model1: @model1
          model2: @model2
          attribute: 'attr'
          rows: 5
        $('#jasmine_content').html(@view.render().el)

      it 'should have a textarea for control 1', ->
        expect(@view.$('.first.control')).toContainElement('.textarea textarea')

      it 'should have a textarea for control 2', ->
        expect(@view.$('.second.control')).toContainElement('.textarea textarea')
