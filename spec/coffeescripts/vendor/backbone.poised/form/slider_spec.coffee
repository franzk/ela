describe 'Backbone.Poised.Slider', ->
  beforeEach ->
    @model = new Backbone.Model(foo: 10)
    @view = new Backbone.Poised.Slider
      model: @model
      attribute: 'foo'
      minValue: -15
      maxValue: 15
    $('#jasmine_content').html(@view.render().el)

  it 'should extend the Backbone.Poised.View', ->
    expect(@view).toBeInstanceOf(Backbone.Poised.View)

  describe 'Instantiations', ->
    it 'should require `model` option', ->
      expect => new Backbone.Poised.Slider()
      .toThrow new Error('Missing `model` option')
      expect => new Backbone.Poised.Slider(model: @model)
      .not.toThrow new Error('Missing `model` option')

    it 'should require `attribute` option', ->
      expect => new Backbone.Poised.Slider(model: @model)
      .toThrow new Error('Missing `attribute` option')
      expect => new Backbone.Poised.Slider(model: @model, attribute: 'foo')
      .not.toThrow new Error('Missing `attribute` option')

    it 'should define slider @attribute', ->
      view = new Backbone.Poised.Slider
        model: @model
        attribute: 'foo'
      expect(view.attribute).toEqual('foo')

    it 'should define default options', ->
      view = new Backbone.Poised.Slider
        model: @model
        attribute: 'foo'
      expect(view.startValue).toEqual(0)
      expect(view.range).toEqual(100)

    it 'should define slider @range and @startValue from `minValue` and `maxValue` options', ->
      expect(@view.startValue).toEqual(-15)
      expect(@view.range).toEqual(30)

  describe 'Model Changes', ->
    it 'should update the sliders handle position respecting upper bounds', ->
      expect(@view.$handle.attr('style')).toMatch(/left: 83.33%/)
      @model.set foo: 30
      expect(@view.$handle.attr('style')).toMatch(/left: 100%/)

    it 'should update the sliders handle position respecting lower bounds', ->
      expect(@view.$handle.attr('style')).toMatch(/left: 83.33%/)
      @model.set foo: -100
      expect(@view.$handle.attr('style')).toMatch(/left: 0%/)

  describe 'Element', ->
    it 'should render the slider template', ->
      expect(@view.el).toContainElement('div.bar')
      expect(@view.el).toContainElement('div.handle')
      expect(@view.$handle.attr('style')).toMatch(/left: 83.33%/)

    it 'should have class poised', ->
      expect(@view.el).toHaveClass('poised')

    it 'should have class slider', ->
      expect(@view.el).toHaveClass('slider')

  describe '#updateHandlePosition', ->
    it 'should set the css left attribute', ->
      @view.updateHandlePosition(@view.model, -10)
      expect(@view.$handle.attr('style')).toMatch(/left: 16.67%/)

  describe '#calculateHandlePosition', ->
    it 'should have a lower bound of 0%', ->
      expect(@view.calculateHandlePosition(-100)).toEqual(0)

    it 'should have an upper bound of 100%', ->
      expect(@view.calculateHandlePosition(100)).toEqual(100)

  describe '#calculateAttributeValue', ->
    it 'calculated value has lower bound of minValue', ->
      @view.$bar.width = -> 50
      expect(@view.calculateAttributeValue(-100)).toEqual(-15)

    it 'calculated value has upper bound of maxValue', ->
      @view.$bar.width = -> 50
      expect(@view.calculateAttributeValue(100)).toEqual(15)

    it 'calculated value is correct in relation to bar width', ->
      @view.$bar.width = -> 50
      expect(@view.calculateAttributeValue(25)).toEqual(0)

  describe 'Touch Gesture', ->
    beforeEach ->
      @tapChange       = jasmine.createSpy('tapChange')
      @liveChangeStart = jasmine.createSpy('liveChangeStart')
      @liveChange      = jasmine.createSpy('liveChange')
      @liveChangeEnd   = jasmine.createSpy('liveChangeEnd')
      @view.on 'tapChange', @tapChange
      @view.on 'liveChangeStart', @liveChangeStart
      @view.on 'liveChange', @liveChange
      @view.on 'liveChangeEnd', @liveChangeEnd

    it 'should trigger `tapChange` event, on tap', ->
      @view.$el.trigger
        type: 'tap'
        gesture:
          center:
            clientX: 50
      expect(@tapChange).toHaveBeenCalled()

    it 'should trigger `liveChangeStart` event, on horizontal panstart', ->
      @view.$el.trigger
        type: 'panstart'
        gesture:
          deltaX: 50
          deltaY: 5
      expect(@liveChangeStart).toHaveBeenCalled()

    it 'should not trigger `liveChangeStart` event, on vertical panstart', ->
      @view.$el.trigger
        type: 'panstart'
        gesture:
          deltaX: 5
          deltaY: 50
      expect(@liveChangeStart).not.toHaveBeenCalled()

    it 'should trigger `liveChangeStart` event, on press', ->
      @view.$el.trigger
        type: 'press'
        gesture:
          center:
            clientX: 50
      expect(@liveChangeStart).toHaveBeenCalled()

    it 'should trigger `liveChange` event, on pan', ->
      @view.$el.trigger
        type: 'panstart'
        gesture:
          deltaX: 50
          deltaY: 5
      @view.$el.trigger
        type: 'pan'
        gesture:
          deltaX: 100
          center:
            clientX: 100
      expect(@liveChange).toHaveBeenCalled()

    it 'should trigger `liveChangeEnd` event, on panend', ->
      @view.$el.trigger
        type: 'panstart'
        gesture:
          deltaX: 50
          deltaY: 5
      @view.$el.trigger 'panend'
      expect(@liveChangeEnd).toHaveBeenCalled()

    it 'should trigger `liveChangeEnd` event, on pressup', ->
      @view.$el.trigger
        type: 'press'
        gesture:
          center:
            clientX: 50
      @view.$el.trigger 'pressup'
      expect(@liveChangeEnd).toHaveBeenCalled()
