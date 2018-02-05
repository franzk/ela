describe 'Backbone.Poised.Textfield', ->
  beforeEach ->
    @model = new Backbone.Model(strAttr: 'foo', numAttr: 10)

  describe 'Instantiation', ->
    it 'should require `model` option', ->
      expect => new Backbone.Poised.Textfield()
      .toThrow new Error('Missing `model` option')
      expect => new Backbone.Poised.Textfield(model: @model)
      .not.toThrow new Error('Missing `model` option')

    it 'should require `attribute` option', ->
      expect => new Backbone.Poised.Textfield(model: @model)
      .toThrow new Error('Missing `attribute` option')
      expect => new Backbone.Poised.Textfield(model: @model, attribute: 'strAttr')
      .not.toThrow new Error('Missing `attribute` option')

    it 'should define slider @attribute', ->
      view = new Backbone.Poised.Textfield
        model: @model, attribute: 'strAttr'
      expect(view.attribute).toEqual('strAttr')

    it 'should use default options', ->
      view = new Backbone.Poised.Textfield
        model: @model, attribute: 'strAttr'
      expect(view.options.type).toEqual('text')
      expect(view.options.autofocus).toEqual(false)
      expect(view.options.clearOnFocus).toEqual(false)
      expect(view.options.stepSize).toBeUndefined()
      expect(view.options.precision).toBeUndefined()
      expect(view.options.minValue).toEqual(null)
      expect(view.options.maxValue).toEqual(null)
      expect(view.options.validate).toEqual(true)

    it 'should use given `range` array option for minValue/maxValue', ->
      view = new Backbone.Poised.Textfield
        model: @model, attribute: 'strAttr', range: [-15, 15]
      expect(view.options.minValue).toEqual(-15)
      expect(view.options.maxValue).toEqual(15)

    it 'should take `type` option', ->
      view = new Backbone.Poised.Textfield
        model: @model, attribute: 'strAttr', type: 'number'
      expect(view.options.type).toEqual('number')

    it 'should take `placeholder` option', ->
      view = new Backbone.Poised.Textfield
        model: @model, attribute: 'strAttr', placeholder: 'My very important placeholder ...'
      expect(view.options.placeholder).toEqual('My very important placeholder ...')

    it 'should take `autofocus` option', ->
      view = new Backbone.Poised.Textfield
        model: @model, attribute: 'strAttr', autofocus: true
      expect(view.options.autofocus).toEqual(true)

    it 'should take `clearOnFocus` option', ->
      view = new Backbone.Poised.Textfield
        model: @model, attribute: 'strAttr', clearOnFocus: true
      expect(view.options.clearOnFocus).toEqual(true)

    it 'should take `stepSize` option', ->
      view = new Backbone.Poised.Textfield
        model: @model, attribute: 'numAttr', stepSize: 0.1
      expect(view.options.stepSize).toEqual(0.1)

    it 'should take `precision` option', ->
      view = new Backbone.Poised.Textfield
        model: @model, attribute: 'strAttr', precision: 3
      expect(view.options.precision).toEqual(3)

    it 'should take `minValue`/`maxValue` options', ->
      view = new Backbone.Poised.Textfield
        model: @model, attribute: 'strAttr', minValue: -15, maxValue: 15
      expect(view.options.minValue).toEqual(-15)
      expect(view.options.maxValue).toEqual(15)

    it 'should take `unit` option', ->
      view = new Backbone.Poised.Textfield
        model: @model, attribute: 'strAttr', unit: 'km/h'
      expect(view.options.unit).toEqual('km/h')

    it 'should take `validate` option', ->
      view = new Backbone.Poised.Textfield
        model: @model, attribute: 'strAttr', validate: false
      expect(view.options.validate).toEqual(false)

    it 'should calculate the `precision` options according to given `stepSize` option', ->
      view = new Backbone.Poised.Textfield
        model: @model, attribute: 'strAttr', stepSize: 0.1
      expect(view.options.precision).toEqual(1)
      view = new Backbone.Poised.Textfield
        model: @model, attribute: 'strAttr', stepSize: 0.01
      expect(view.options.precision).toEqual(2)
      view = new Backbone.Poised.Textfield
        model: @model, attribute: 'strAttr', stepSize: 0.001
      expect(view.options.precision).toEqual(3)

  describe 'Element', ->
    describe 'for `number` type field', ->
      beforeEach ->
        @view = new Backbone.Poised.Textfield
          model: @model
          type: 'number'
          attribute: 'numAttr'
          placeholder: 'My very important placeholder'
          autofocus: true
          stepSize: 0.1
          minValue: -15
          maxValue: 15
        $('#jasmine_content').html(@view.render().el)

      describe 'given `unit` option', ->
        beforeEach ->
          @view = new Backbone.Poised.Textfield
            model: @model
            type: 'number'
            attribute: 'numAttr'
            unit: 'km/h'
          $('#jasmine_content').html(@view.render().el)

        it 'should render the measurement unit', ->
          expect(@view.el).toContainElement('abbr')
          expect(@view.$('abbr')).toHaveText('km/h')

      it 'should render the input element', ->
        expect(@view.el).toContainElement('input.poised')
        expect(@view.$input.attr('name')).toEqual('numAttr')
        expect(@view.$input.attr('type')).toEqual('number')
        expect(@view.$input.attr('placeholder')).toEqual('My very important placeholder')
        expect(@view.$input.attr('autofocus')).toEqual('autofocus')
        expect(@view.$input.attr('min')).toEqual('-15')
        expect(@view.$input.attr('max')).toEqual('15')
        expect(@view.$input.attr('step')).toEqual('0.1')

      it 'should render the measurement unit', ->
        expect(@view.el).not.toContainElement('abbr')

      it 'should set the correct input value from model', ->
        expect(@view.$input.val()).toEqual('10.0')

      it 'should have class poised', ->
        expect(@view.el).toHaveClass('poised')

      it 'should have class textfield', ->
        expect(@view.el).toHaveClass('textfield')

  describe 'Model Changes', ->
    beforeEach ->
      @model = new Backbone.Model(strAttr: 'foo', numAttr: 10)
      @view = new Backbone.Poised.Textfield
        model: @model
        type: 'number'
        attribute: 'numAttr'
      $('#jasmine_content').html(@view.render().el)

    it 'should set the input field value', ->
      expect(@view.$input.val()).toEqual('10')
      @model.set(numAttr: 20)
      expect(@view.$input.val()).toEqual('20')

  describe 'Input Value Changes', ->
    beforeEach ->
      @model = new Backbone.Model(strAttr: 'foo', numAttr: 10)
      @model.validate = -> # stub to create a spy on
      @view = new Backbone.Poised.Textfield
        model: @model
        type: 'number'
        attribute: 'numAttr'
      $('#jasmine_content').html(@view.render().el)

    it 'should set the model attribute', ->
      @view.$input.val('20')
      @view.$input.trigger('focusout')
      expect(@model.get('numAttr')).toEqual(20)

    it 'should invoke validate if enabled', ->
      spyOn(@model, 'validate').and.returnValue(true)
      @view.$input.val('20')
      @view.$input.trigger('focusout')
      expect(@model.get('numAttr')).toEqual(20)
      expect(@model.validate).toHaveBeenCalled()

  describe '#readInput', ->
    describe 'for `number` type field', ->
      beforeEach ->
        @model = new Backbone.Model(numAttr: 5)
        @model.validate = -> # stub to create a spy on
        @view = new Backbone.Poised.Textfield
          model: @model
          type: 'number'
          attribute: 'numAttr'
          minValue: 0
          maxValue: 10
        $('#jasmine_content').html(@view.render().el)

      it 'should restrict the input value to minValue as lower bound', ->
        @view.$input.focusin()
        @view.$input.val('-100')
        @view.$input.focusout()
        expect(@model.get('numAttr')).toEqual(0)
        expect(@view.$input.val()).toEqual('0')

      it 'should restrict the input value to maxValue as upper bound', ->
        @view.$input.focusin()
        @view.$input.val('100')
        @view.$input.focusout()
        expect(@model.get('numAttr')).toEqual(10)
        expect(@view.$input.val()).toEqual('10')

      it 'should restore the value on blur without value', ->
        @view.$input.focusin()
        @view.$input.focusout()
        expect(@view.$input.val()).toEqual('5')

      it 'should restore the value on blur with invalid number', ->
        # Otherwise, this test will fail in browsers that reject to
        # set the value of a text field of type 'number' to NaNs like
        # '0.'
        @view.$input.attr(type: 'text')

        @view.$input.focusin()
        @view.$input.val('0.')
        @view.$input.focusout()
        expect(@model.get('numAttr')).toEqual(5)
        expect(@view.$input.val()).toEqual('5')

      it 'should validate the model if enabled', ->
        spyOn(@model, 'validate').and.returnValue(true)
        @view.$input.focusin()
        @view.$input.val('8')
        @view.$input.focusout()
        expect(@model.get('numAttr')).toEqual(8)
        expect(@model.validate).toHaveBeenCalled()

    describe 'for `text` type field', ->
      beforeEach ->
        @model = new Backbone.Model(strAttr: 'default')
        @model.validate = -> # stub to create a spy on
        @view = new Backbone.Poised.Textfield
          model: @model
          attribute: 'strAttr'
        $('#jasmine_content').html(@view.render().el)

      it 'should set the input value', ->
        expect(@model.get('strAttr')).toEqual('default')

        @view.$input.focusin()
        @view.$input.val('')
        @view.$input.focusout()
        expect(@model.get('strAttr')).toEqual('')

        @view.$input.focusin()
        @view.$input.val('test input')
        @view.$input.focusout()
        expect(@model.get('strAttr')).toEqual('test input')

      it 'should validate the model if enabled', ->
        spyOn(@model, 'validate').and.returnValue(true)
        @view.$input.focusin()
        @view.$input.val('text')
        @view.$input.focusout()
        expect(@model.get('strAttr')).toEqual('text')
        expect(@model.validate).toHaveBeenCalled()

  describe '#setValue', ->
    beforeEach ->

    describe 'for `number` type field', ->
      it 'should convert the value to fixed number with precision from options', ->
        @model = new Backbone.Model(numAttr: 5)
        @view = new Backbone.Poised.Textfield
          model: @model
          type: 'number'
          attribute: 'numAttr'
          precision: 2
        $('#jasmine_content').html(@view.render().el)

        @view.setValue(@model, 20.33333333)
        expect(@view.$input.val()).toEqual('20.33')

      it 'should not convert the value to fixed number without precision set', ->
        @model = new Backbone.Model(numAttr: 5)
        @view = new Backbone.Poised.Textfield
          model: @model
          type: 'number'
          attribute: 'numAttr'
        $('#jasmine_content').html(@view.render().el)

        @view.setValue(@model, 20.33333333)
        expect(@view.$input.val()).toEqual('20.33333333')

    describe 'for `text` type field', ->
      beforeEach ->
        @model = new Backbone.Model(strAttr: 'Abc')
        @view = new Backbone.Poised.Textfield
          model: @model
          attribute: 'strAttr'
        $('#jasmine_content').html(@view.render().el)

      it 'should set the input field value', ->
        expect(@view.$input.val()).toEqual('Abc')
        @view.setValue(@model, 'Def')
        expect(@view.$input.val()).toEqual('Def')

    describe 'generic', ->
      beforeEach ->
        @model = new Backbone.Model(strAttr: 'Abc')
        @view = new Backbone.Poised.Textfield
          model: @model
          attribute: 'strAttr'
        $('#jasmine_content').html(@view.render().el)

      it 'should take the models attribute if no arguments given', ->
        @view.setValue()
        expect(@view.$input.val()).toEqual('Abc')

      it 'should take the given arguments', ->
        expect(@view.$input.val()).toEqual('Abc')
        @view.setValue(@model, 'SomeValue')
        expect(@view.$input.val()).toEqual('SomeValue')

  describe '#clearInputValue', ->
    describe 'with `clear on focus` enabled', ->
      beforeEach ->
        @model = new Backbone.Model(numAttr: 5)
        @view = new Backbone.Poised.Textfield
          model: @model
          type: 'number'
          attribute: 'numAttr'
          clearOnFocus: true
        $('#jasmine_content').html(@view.render().el)

      it 'should clear the input value', ->
        @view.$input.focusin()
        expect(@view.$input.val()).toEqual('')

    describe 'with `clear on focus` disabled', ->
      beforeEach ->
        @model = new Backbone.Model(numAttr: 5)
        @view = new Backbone.Poised.Textfield
          model: @model
          type: 'number'
          attribute: 'numAttr'
          clearOnFocus: false
        $('#jasmine_content').html(@view.render().el)

      it 'should not clear the input value or restore', ->
        expect(@view.$input.val()).toEqual('5')
        @view.$input.focusin()
        expect(@view.$input.val()).toEqual('5')
        @view.$input.focusout()
        expect(@view.$input.val()).toEqual('5')
