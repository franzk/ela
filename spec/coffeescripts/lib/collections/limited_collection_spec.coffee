describe 'ELA.Collections.LimitedCollection', ->
  beforeEach ->
    @model1 = new Backbone.Model(name: 'First', selected: false)
    @model2 = new Backbone.Model(name: 'Second', selected: false)
    @model3 = new Backbone.Model(name: 'Third', selected: false)
    @collection = new ELA.Collections.LimitedCollection(
      [@model1, @model2, @model3]
      limit: 2
    )

    @change = jasmine.createSpy('change:selected')
    @collection.on('change:selected', @change)

    @historyChange = jasmine.createSpy('historyChange')
    @collection.on('historyChange', @historyChange)


  describe 'deselecting a curve', ->
    it 'should remove the curve from array of selected curves', ->
      @model1.set selected: true

      expect(@collection.history).toEqual([@model1])
      @model1.set selected: false
      expect(@collection.history).toEqual([])

      expect(@change).toHaveBeenCalledTimes(2)
      expect(@historyChange).toHaveBeenCalledTimes(2)

  describe 'selecting a model', ->
    it 'should manipulate the history accordingly', ->
      expect(@collection.history).toEqual([])
      @model1.set selected: true
      expect(@collection.history).toEqual([@model1])

      expect(@change).toHaveBeenCalledTimes(1)
      expect(@historyChange).toHaveBeenCalledTimes(1)

    it 'should remove and deselect oldest if collection is at its limit', ->
      @model1.set selected: true
      @model2.set selected: true

      expect(@collection.history).toEqual([@model1, @model2])
      @model3.set selected: true
      expect(@collection.history).toEqual([@model2, @model3])

      expect(@model1.get('selected')).toBeFalsy()

      expect(@change).toHaveBeenCalledTimes(4)
      expect(@historyChange).toHaveBeenCalledTimes(3)

  describe 'adding a selected model', ->
    it 'should manipulate the history accordingly', ->
      model4 = new Backbone.Model(name: 'Fourth', selected: true)

      expect(@collection.history).toEqual([])
      @collection.add(model4)
      expect(@collection.history).toEqual([model4])

      expect(@change).not.toHaveBeenCalled()
      expect(@historyChange).toHaveBeenCalledTimes(1)

    it 'should remove and deselect oldest if collection is at its limit', ->
      model4 = new Backbone.Model(name: 'Fourth', selected: true)

      @model1.set selected: true
      @model2.set selected: true

      expect(@collection.history).toEqual([@model1, @model2])
      @collection.add(model4)
      expect(@collection.history).toEqual([@model2, model4])

      expect(@model1.get('selected')).toBeFalsy()
      expect(@change).toHaveBeenCalledTimes(3)
      expect(@historyChange).toHaveBeenCalledTimes(3)

  describe 'removing a selected model', ->
    it 'should manipulate the history accordingly', ->
      @model1.set selected: true
      @model2.set selected: true

      expect(@collection.history).toEqual([@model1, @model2])
      @collection.remove(@model1)
      expect(@collection.history).toEqual([@model2])

      expect(@change).toHaveBeenCalledTimes(2)
      expect(@historyChange).toHaveBeenCalledTimes(3)

  describe 'resetting', ->
    it 'should manipulate the history accordingly', ->
      @model1.set selected: true
      @model2.set selected: true
      expect(@change).toHaveBeenCalledTimes(2)

      expect(@collection.history).toEqual([@model1, @model2])
      model4 = new Backbone.Model(name: 'Fourth', selected: false)
      model5 = new Backbone.Model(name: 'Fifth', selected: true)
      model6 = new Backbone.Model(name: 'Sixth', selected: true)
      model7 = new Backbone.Model(name: 'Seventh', selected: true)
      model8 = new Backbone.Model(name: 'Eights', selected: false)
      @collection.reset([model4, model5, model6, model7, model8])
      expect(@collection.history).toEqual([model6, model7])

      expect(@change).toHaveBeenCalledTimes(3)
      expect(@historyChange).toHaveBeenCalledTimes(3)
