describe 'Backbone.Poised.Selectbox', ->
  beforeEach ->
    @model = new Backbone.Model(attr: '')
    @view = new Backbone.Poised.Selectbox
      model: @model
      attribute: 'attr'
      placeholder: 'Select foo or bar'
      options: ['foo', 'bar']
      validate: false
    $('#jasmine_content').html(@view.render().el)

  describe 'Instantiation', ->
    it 'should require `model` option', ->
      expect => new Backbone.Poised.Selectbox()
      .toThrow new Error('Missing `model` option')
      expect => new Backbone.Poised.Selectbox(model: @model)
      .not.toThrow new Error('Missing `model` option')

    it 'should require `attribute` option', ->
      expect => new Backbone.Poised.Selectbox(model: @model)
      .toThrow new Error('Missing `attribute` option')
      expect => new Backbone.Poised.Selectbox(model: @model, attribute: 'attr')
      .not.toThrow new Error('Missing `attribute` option')

    it 'should define slider @attribute', ->
      view = new Backbone.Poised.Selectbox
        model: @model, attribute: 'attr'
      expect(view.attribute).toEqual('attr')

    it 'should use default options', ->
      view = new Backbone.Poised.Selectbox
        model: @model, attribute: 'attr'
      expect(view.options.placeholder).toBe(false)
      expect(view.options.options).toEqual([])
      expect(view.options.multiselect).toEqual(false)
      expect(view.options.validate).toEqual(true)

    describe 'placeholder default option', ->
      it 'should default to fallback string without existing attribute', ->
        view = new Backbone.Poised.Selectbox
          model: @model, attribute: 'something'
        expect(view.options.placeholder).toEqual('Please select ...')

      it 'should be false for multiselects', ->
        view = new Backbone.Poised.Selectbox
          model: @model, attribute: 'something', multiselect: true
        expect(view.options.placeholder).toBe(false)

    it 'should use given options', ->
      expect(@view.options.placeholder).toEqual('Select foo or bar')
      expect(@view.options.options).toEqual(['foo', 'bar'])
      expect(@view.options.validate).toBe(false)

    it 'should use default placeholder string', ->
      view = new Backbone.Poised.Selectbox
        model: @model, attribute: 'attr', placeholder: true
      expect(view.options.placeholder).toEqual('Please select ...')

  describe 'Element', ->
    it 'should render a select element', ->
      expect(@view.el).toContainElement('select')

    it 'should render given select options in the correct order', ->
      expect(@view.$('select option:nth-child(2)')).toHaveData('value', 'foo')
      expect(@view.$('select option:nth-child(3)')).toHaveData('value', 'bar')

    it 'should render a selected placeholder option', ->
      $firstOption = @view.$('select option').first()
      expect($firstOption).toExist()
      expect($firstOption).toBeDisabled()
      # toBeSelected() is based on jquery's is(':selected'), which
      # always returns false in phantomjs if the option is disabled
      expect($firstOption.attr('selected')).toBe('selected')
      expect($firstOption.text()).toBe('Select foo or bar')

    describe 'single-selectbox value', ->
      beforeEach ->
        @model = new Backbone.Model(attr: 'foo')
        @view = new Backbone.Poised.Selectbox
          model: @model
          attribute: 'attr'
          placeholder: 'Select foo or bar'
          options: ['foo', 'bar']
          validate: false
        $('#jasmine_content').html(@view.render().el)

      it 'should render the initial model value selected', ->
        $fooOption = @view.$('select option').filter ->
          $(this).data('value') is 'foo'
        expect($fooOption).toBeSelected()

      it 'should render the new value on model change', ->
        $fooOption = @view.$('select option').filter ->
          $(this).data('value') is 'foo'
        $barOption = @view.$('select option').filter ->
          $(this).data('value') is 'bar'
        expect($fooOption).toBeSelected()
        expect($barOption).not.toBeSelected()
        @model.set attr: 'bar'
        expect($fooOption).not.toBeSelected()
        expect($barOption).toBeSelected()

      it 'should change the model attribute value, on value change', ->
        @view.$('select').val('bar').change()
        expect(@model.get('attr')).toEqual('bar')

    describe 'multi-selectbox value', ->
      beforeEach ->
        @model = new Backbone.Model(attr: ['foo', 'baz'])
        @view = new Backbone.Poised.Selectbox
          model: @model
          attribute: 'attr'
          placeholder: 'Select something'
          options: ['foo', 'bar', 'fu', 'baz']
          multiselect: true
          validate: false
        $('#jasmine_content').html(@view.render().el)
        @$fooOption = @view.$('select option').filter ->
          $(this).data('value') is 'foo'
        @$barOption = @view.$('select option').filter ->
          $(this).data('value') is 'bar'
        @$fuOption = @view.$('select option').filter ->
          $(this).data('value') is 'fu'
        @$bazOption = @view.$('select option').filter ->
          $(this).data('value') is 'baz'

      it 'should render the initial model value selected', ->
        expect(@$fooOption).toBeSelected()
        expect(@$barOption).not.toBeSelected()
        expect(@$fuOption).not.toBeSelected()
        expect(@$bazOption).toBeSelected()

      it 'should render the new value on model change', ->
        expect(@$fooOption).toBeSelected()
        expect(@$barOption).not.toBeSelected()
        expect(@$fuOption).not.toBeSelected()
        expect(@$bazOption).toBeSelected()
        @model.set attr: ['foo', 'bar', 'fu', 'baz']
        expect(@$fooOption).toBeSelected()
        expect(@$barOption).toBeSelected()
        expect(@$fuOption).toBeSelected()
        expect(@$bazOption).toBeSelected()

      it 'should change the model attribute value, on value change', ->
        @view.$('select').val(['fu']).change()
        expect(@model.get('attr')).toEqual(['fu'])
