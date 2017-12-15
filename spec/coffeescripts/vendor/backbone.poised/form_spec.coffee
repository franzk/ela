window.testModelFormFields = [
  { attribute: 'foo', type: 'number' }
  { attribute: 'bar', type: 'text' }
  { attribute: 'fu',  type: 'select', options: ['good', 'okay', 'bad'], placeholder: 'What do you think?' }
  { attribute: 'baz', range: [0, 10] }
]

window.testModelFormWithGroupsFields = [
  { attribute: 'foo', type: 'number', group: 'firstGroup' }
  { attribute: 'bar', type: 'text', group: 'secondGroup' }
  { attribute: 'fu',  type: 'select', options: ['good', 'okay', 'bad'], placeholder: 'What do you think?', group: 'secondGroup' }
  { attribute: 'baz', range: [0, 10], group: 'thirdGroup' }
]

class TestModel extends Backbone.Model
  formFields: window.testModelFormFields

class TestModelWithGroups extends Backbone.Model
  formFields: window.testModelFormWithGroupsFields

describe 'Backbone.Poised.Form', ->
  beforeEach ->
    attrs =
      foo: 42
      bar: 'Some text'
      fu: 'okay'
      baz: 5
    @model = new TestModel(attrs)
    @modelWithGroups = new TestModelWithGroups(attrs)

  describe 'Instantiantion', ->
    beforeEach ->
      @view = new Backbone.Poised.Form(model: @model)

    it 'should require `model` option', ->
      expect => new Backbone.Poised.Textfield()
      .toThrow new Error('Missing `model` option')
      expect => new Backbone.Poised.Textfield(model: @model)
      .not.toThrow new Error('Missing `model` option')

    it 'should take field info from options', ->
      fields = [
        { attribute: 'foo' }
        { attribute: 'bar' }
      ]
      view = new Backbone.Poised.Form
        model: @model
        fields: fields
      expect(view.fields).toEqual fields

    it 'should take field info from model `@formFields`', ->
      view = new Backbone.Poised.Form(model: @model)
      expect(view.fields).toEqual window.testModelFormFields

  describe 'Element', ->
    describe 'without groups', ->
      beforeEach ->
        @view = new Backbone.Poised.Form(model: @model)
        $('#jasmine_content').html(@view.render().el)

      it 'should be of type `tag`', ->
        expect(@view.$el.is('form')).toBeTruthy()

      it 'should have class `poised`', ->
        expect(@view.el).toHaveClass('poised')

      it 'should contain a number input for `foo`', ->
        expect(@view.el).toContainElement('.control .poised.textfield input[name=foo]')
        expect(@view.$('.control .poised.textfield input[name=foo]')).toHaveAttr('type', 'number')

      it 'should contain a text input for `bar`', ->
        expect(@view.el).toContainElement('.control .poised.textfield input[name=bar]')
        expect(@view.$('.control .poised.textfield input[name=bar]')).toHaveAttr('type', 'text')

      it 'should contain a select for `fu`', ->
        expect(@view.el).toContainElement('.control .poised.selectbox select[name=fu]')

      it 'should contain a number input and a slider for `baz`', ->
        expect(@view.el).toContainElement('.control .poised.textfield input[name=baz]')
        expect(@view.$('.control .poised.textfield input[name=baz]')).toHaveAttr('type', 'number')
        expect(@view.el).toContainElement('.control .poised.slider')

    describe 'with groups', ->
      beforeEach ->
        @view = new Backbone.Poised.Form(model: @modelWithGroups, group: { by: 'group', collapsible: ['secondGroup', 'thirdGroup'], collapsed: ['thirdGroup'] })
        $('#jasmine_content').html(@view.render().el)

      describe 'its firstGroup', ->
        it 'should contain all elements', ->
          expect(@view.el).toContainElement('.anchor:nth-child(1)')
          expect(@view.$('.anchor:nth-child(1)')).toContainText('First Group')
          expect(@view.el).toContainElement('.poised.control-group:nth-child(2) .control .poised.textfield input[name=foo]')

        it 'should be un-collapsed', ->
          expect(@view.$('.anchor:nth-child(1)')).not.toHaveClass('collapsed')

        it 'should not be collapsible', ->
          expect(@view.$('.anchor:nth-child(1)')).not.toHaveClass('collapsible')

      describe 'its secondGroup', ->
        it 'should contain all elements', ->
          expect(@view.el).toContainElement('.anchor:nth-child(3)')
          expect(@view.$('.anchor:nth-child(3)')).toContainText('Second Group')
          expect(@view.el).toContainElement('.poised.control-group:nth-child(4) .control:nth-child(1) .poised.textfield input[name=bar]')
          expect(@view.el).toContainElement('.poised.control-group:nth-child(4) .control:nth-child(2) .poised.selectbox select[name=fu]')

        it 'should be un-collapsed', ->
          expect(@view.$('.anchor:nth-child(3)')).not.toHaveClass('collapsed')

        it 'should be collapsible', ->
          expect(@view.$('.anchor:nth-child(3)')).toHaveClass('collapsible')

      describe 'its thirdGroup', ->
        it 'should contain all elements', ->
          expect(@view.el).toContainElement('.anchor:nth-child(5)')
          expect(@view.$('.anchor:nth-child(5)')).toContainText('Third Group')
          expect(@view.el).toContainElement('.poised.control-group:nth-child(6) .control .poised.textfield input[name=baz]')
          expect(@view.el).toContainElement('.poised.control-group:nth-child(6) .control .poised.slider')

        it 'should be collapsed', ->
          expect(@view.$('.anchor:nth-child(5)')).toHaveClass('collapsed')

        it 'should be collapsible', ->
          expect(@view.$('.anchor:nth-child(5)')).toHaveClass('collapsible')
