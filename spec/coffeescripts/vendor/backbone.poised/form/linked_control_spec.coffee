describe 'Backbone.Poised.LinkedControl', ->
  beforeEach ->
    @model1 = new Backbone.Model(attr: 10)
    @model2 = new Backbone.Model(attr: 10)

  it 'should extend Backbone.Poised.View', ->
    view = new Backbone.Poised.LinkedControl
      model1: @model1
      model2: @model2
      attribute: 'attr'
    expect(view).toBeInstanceOf(Backbone.Poised.View)

  describe 'Instantiations', ->
    it 'should require `model1` option', ->
      expect -> new Backbone.Poised.LinkedControl()
      .toThrow new Error('Missing `model1` option')
      expect => new Backbone.Poised.LinkedControl(model1: @model1)
      .not.toThrow new Error('Missing `model1` option')

    it 'should require `model2` option', ->
      expect => new Backbone.Poised.LinkedControl(model1: @model1)
      .toThrow new Error('Missing `model2` option')
      expect => new Backbone.Poised.LinkedControl(model1: @model1, model2: @model2)
      .not.toThrow new Error('Missing `model2` option')

    it 'should require an `attribute` option', ->
      expect => new Backbone.Poised.LinkedControl(model1: @model1, model2: @model2)
      .toThrow new Error('Missing `attribute` option')
      expect => new Backbone.Poised.LinkedControl(model1: @model1, model2: @model2, attribute: 'attr')
      .not.toThrow new Error('Missing `attribute` option')

    it 'should take `isLinked` option for state model', ->
      view = new Backbone.Poised.LinkedControl
        model1: @model1
        model2: @model2
        attribute: 'attr'
        isLinked: false
      expect(view.linkState.get('isLinked')).toBeFalsy()

    it 'should set `isLinked` state to `true` by default', ->
      view = new Backbone.Poised.LinkedControl
        model1: @model1
        model2: @model2
        attribute: 'attr'
      expect(view.linkState.get('isLinked')).toBeTruthy()

    it 'should take `label` option', ->
      view = new Backbone.Poised.LinkedControl
        model1: @model1
        model2: @model2
        attribute: 'attr'
        label: 'My Setting'
      expect(view.label).toEqual('My Setting')

  describe 'view', ->
    beforeEach ->
      @view = new Backbone.Poised.LinkedControl
        model1: @model1
        model2: @model2
        isLinked: false
        attribute: 'attr'
      $('#jasmine_content').html(@view.render().el)

    describe 'Element', ->
      it 'should have class `poised`', ->
        expect(@view.el).toHaveClass('poised')

      it 'should have class `linked-control`', ->
        expect(@view.el).toHaveClass('linked-control')

      it 'should have class `attr`', ->
        expect(@view.el).toHaveClass('attr')

      it 'should have element `.first.control`', ->
        expect(@view.el).toContainElement('div.first.control')

      it 'should have element `.second.control`', ->
        expect(@view.el).toContainElement('div.second.control')

      it 'should have element `.link.icon`', ->
        expect(@view.el).toContainElement('div.link.icon')

      it 'should have the unlinked icon', ->
        expect(@view.$link).toHaveClass('unlinked')

      it 'should add attribute classes for each control', ->
        expect(@view.$control1).toHaveClass('attr')
        expect(@view.$control2).toHaveClass('attr')

    describe 'on changing linked state to false', ->
      it 'should toggle class `.unlinked`', ->
        expect(@view.$link).toHaveClass('unlinked')
        @view.toggleLinkState()
        expect(@view.$link).not.toHaveClass('unlinked')

    describe 'linked state', ->
      describe 'on model change', ->
        it 'should change the other models value', ->
          @view.linkState.set isLinked: true
          expect(@model1.get('attr')).toEqual(10)
          expect(@model2.get('attr')).toEqual(10)
          @model1.set attr: 15
          expect(@model1.get('attr')).toEqual(15)
          expect(@model2.get('attr')).toEqual(15)

    describe 'unlinked state', ->
      describe 'on model change', ->
        it 'should change the other models value', ->
          @view.linkState.set isLinked: false
          expect(@model1.get('attr')).toEqual(10)
          expect(@model2.get('attr')).toEqual(10)
          @model1.set attr: 15
          expect(@model1.get('attr')).toEqual(15)
          expect(@model2.get('attr')).toEqual(10)

  describe 'view with label', ->
    beforeEach ->
      @view = new Backbone.Poised.LinkedControl
        model1: @model1
        model2: @model2
        attribute: 'attr'
        label: 'My Label'
      $('#jasmine_content').html(@view.render().el)

    describe 'Element', ->
      it 'should render correct label', ->
        expect(@view.$el).toContainElement('div.info label')
        expect(@view.$('label').html()).toEqual('My Label')

  describe 'view while locale exists', ->
    beforeEach ->
      ELA.labels = flattenObject
        formFields:
          attr:
            label: 'Localized Label'
      @view = new Backbone.Poised.LinkedControl
        model1: @model1
        model2: @model2
        attribute: 'attr'
      $('#jasmine_content').html(@view.render().el)

    afterEach ->
      ELA.labels = {}

    describe 'Element', ->
      it 'should render localized label', ->
        expect(@view.$el).toContainElement('div.info label')
        expect(@view.$('label').html()).toEqual('Localized Label')

  describe 'view with localePrefix', ->
    beforeEach ->
      ELA.labels = flattenObject
        formFields:
          attr:
            label: 'Localized Label'
        myNamespace:
          formFields:
            attr:
              label: 'Namespaced Label'
      @view = new Backbone.Poised.LinkedControl
        model1: @model1
        model2: @model2
        attribute: 'attr'
        localePrefix: ['myNamespace']
      $('#jasmine_content').html(@view.render().el)

    afterEach ->
      ELA.labels = {}

    describe 'Element', ->
      it 'should render localized label', ->
        expect(@view.$el).toContainElement('div.info label')
        expect(@view.$('label').html()).toEqual('Namespaced Label')
