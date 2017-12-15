describe 'Backbone.Poised.BaseControl', ->
  beforeEach ->
    @model = new Backbone.Model(fooBar: 10)

  it 'should extend Backbone.Poised.View', ->
    @view = new Backbone.Poised.BaseControl(model: @model, attribute: 'fooBar')
    expect(@view).toBeInstanceOf(Backbone.Poised.View)

  describe 'Instantiations', ->
    it 'should require `model` option', ->
      expect -> new Backbone.Poised.BaseControl()
      .toThrow new Error('Missing `model` option')
      expect => new Backbone.Poised.BaseControl(model: @model)
      .not.toThrow new Error('Missing `model` option')

    it 'should require `attribute` option', ->
      expect => new Backbone.Poised.BaseControl(model: @model)
      .toThrow new Error('Missing `attribute` option')
      expect =>
        new Backbone.Poised.BaseControl(model: @model, attribute: 'fooBar')
      .not.toThrow new Error('Missing `attribute` option')

    it 'should take `label` option', ->
      view = new Backbone.Poised.BaseControl
        model: @model
        attribute: 'fooBar'
        label: 'My Setting'
      expect(view.label).toEqual('My Setting')

  describe 'view', ->
    beforeEach ->
      @view = new Backbone.Poised.BaseControl
        model: @model
        attribute: 'fooBar'
      $('#jasmine_content').html(@view.render().el)

    describe 'Element', ->
      it 'should be of class `poised`', ->
        expect(@view.$el).toHaveClass('poised')

      it 'should be of class `control`', ->
        expect(@view.$el).toHaveClass('control')

      it 'should be of class `fooBar`, which is the controlled attribute name', ->
        expect(@view.$el).toHaveClass('fooBar')

      it 'should render label labelized attribute', ->
        expect(@view.$el).toContainElement('div.info label')
        expect(@view.$el).toContainElement('div.info div.hint')
        expect(@view.$('label').html()).toEqual('Foo Bar')

  describe 'view with label', ->
    beforeEach ->
      @view = new Backbone.Poised.BaseControl
        model: @model
        attribute: 'fooBar'
        label: 'My Label'
      $('#jasmine_content').html(@view.render().el)

    describe 'Element', ->
      it 'should render correct label', ->
        expect(@view.$el).toContainElement('div.info label')
        expect(@view.$el).toContainElement('div.info div.hint')
        expect(@view.$('label').html()).toEqual('My Label')

  describe 'view while locale exists', ->
    beforeEach ->
      ELA.labels = flattenObject
        formFields:
          fooBar:
            label: 'Localized Label'
      @view = new Backbone.Poised.BaseControl
        model: @model
        attribute: 'fooBar'
      $('#jasmine_content').html(@view.render().el)

    afterEach ->
      ELA.labels = {}

    describe 'Element', ->
      it 'should render localized label', ->
        expect(@view.$el).toContainElement('div.info label')
        expect(@view.$el).toContainElement('div.info div.hint')
        expect(@view.$('label').html()).toEqual('Localized Label')

  describe 'view with localePrefix', ->
    beforeEach ->
      ELA.labels = flattenObject
        formFields:
          fooBar:
            label: 'Localized Label'
        myNamespace:
          formFields:
            fooBar:
              label: 'Namespaced Label'
      @view = new Backbone.Poised.BaseControl
        model: @model
        attribute: 'fooBar'
        localePrefix: ['myNamespace']
      $('#jasmine_content').html(@view.render().el)

    afterEach ->
      ELA.labels = {}

    describe 'Element', ->
      it 'should render localized label', ->
        expect(@view.$el).toContainElement('div.info label')
        expect(@view.$el).toContainElement('div.info div.hint')
        expect(@view.$('label').html()).toEqual('Namespaced Label')
