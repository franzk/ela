window.testModelFormFields = [
  { attribute: 'foo', type: 'number' }
  { attribute: 'bar', type: 'text' }
  { attribute: 'fu',  type: 'select', options: ['good', 'okay', 'bad'], placeholder: 'What do you think?' }
  { attribute: 'baz', range: [0, 10] }
]

class TestModel extends Backbone.Model
  formFields: window.testModelFormFields

describe 'Backbone.Poised.LinkedForm', ->
  beforeEach ->
    @model1 = new TestModel
      foo: 42
      bar: 'Some text'
      fu: 'okay'
      baz: 5
    @model2 = new TestModel
      foo: 42
      bar: 'Some text'
      fu: 'okay'
      baz: 5
    @view = new Backbone.Poised.LinkedForm
      model1: @model1
      model2: @model2
    $('#jasmine_content').html(@view.render().el)

  describe 'Instantiantion', ->
    it 'should require `model1` option', ->
      expect => new Backbone.Poised.LinkedForm()
      .toThrow new Error('Missing `model1` option')
      expect => new Backbone.Poised.LinkedForm(model1: @model1)
      .not.toThrow new Error('Missing `model1` option')

    it 'should require `model2` option', ->
      expect => new Backbone.Poised.LinkedForm(model1: @model1)
      .toThrow new Error('Missing `model2` option')
      expect => new Backbone.Poised.LinkedForm(model1: @model1, model2: @model2)
      .not.toThrow new Error('Missing `model2` option')

    it 'should take field info from options', ->
      fields = [
        { attribute: 'foo' }
        { attribute: 'bar' }
      ]
      view = new Backbone.Poised.LinkedForm
        model1: @model1
        model2: @model2
        fields: fields
      expect(view.fields).toEqual fields

    it 'should take field info from model `@formFields`', ->
      view = new Backbone.Poised.LinkedForm
        model1: @model1
        model2: @model2
      expect(view.fields).toEqual window.testModelFormFields

  describe 'Element', ->
    it 'should be of type `tag`', ->
      expect(@view.$el.is('form')).toBeTruthy()

    it 'should have class `poised`', ->
      expect(@view.el).toHaveClass('poised')

    it 'should contain number inputs for `foo` for each model', ->
      expect(@view.el).toContainElement('.linked-control .first.control.foo .poised.textfield input[name=foo]')
      expect(@view.$('.linked-control .first.control.foo .poised.textfield input[name=foo]')).toHaveAttr('type', 'number')
      expect(@view.el).toContainElement('.linked-control .second.control.foo .poised.textfield input[name=foo]')
      expect(@view.$('.linked-control .second.control.foo .poised.textfield input[name=foo]')).toHaveAttr('type', 'number')

    it 'should contain a text inputs for `bar` for each model', ->
      expect(@view.el).toContainElement('.linked-control .first.control.bar .poised.textfield input[name=bar]')
      expect(@view.$('.linked-control .first.control.bar .poised.textfield input[name=bar]')).toHaveAttr('type', 'text')
      expect(@view.el).toContainElement('.linked-control .second.control.bar .poised.textfield input[name=bar]')
      expect(@view.$('.linked-control .second.control.bar .poised.textfield input[name=bar]')).toHaveAttr('type', 'text')

    it 'should contain a selects for `fu` for each model', ->
      expect(@view.el).toContainElement('.linked-control .first.control.fu .poised.selectbox select[name=fu]')
      expect(@view.el).toContainElement('.linked-control .second.control.fu .poised.selectbox select[name=fu]')

    it 'should contain a number inputs and sliders for `fu` for each model', ->
      expect(@view.el).toContainElement('.linked-control .first.control.baz .poised.textfield input[name=baz]')
      expect(@view.$('.linked-control .first.control.baz .poised.textfield input[name=baz]')).toHaveAttr('type', 'number')
      expect(@view.el).toContainElement('.linked-control .first.control.baz .poised.slider')
      expect(@view.el).toContainElement('.linked-control .second.control.baz .poised.textfield input[name=baz]')
      expect(@view.$('.linked-control .second.control.baz .poised.textfield input[name=baz]')).toHaveAttr('type', 'number')
      expect(@view.el).toContainElement('.linked-control .first.control.baz .poised.slider')
