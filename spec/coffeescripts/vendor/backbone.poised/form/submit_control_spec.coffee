describe 'Backbone.Poised.SubmitControl', ->
  beforeEach ->
    @model = new Backbone.Model(attr: 'some text')
    @view = new Backbone.Poised.SubmitControl
      model: @model
      attribute: 'attr'
    $('#jasmine_content').html(@view.render().el)

  it 'should be extending Backbone.Poised.View', ->
    expect(@view).toBeInstanceOf(Backbone.Poised.View)

  describe 'Instantiation', ->
    it 'should set default options', ->
      expect(@view.cancelable).toBeFalsy()
      expect(@view.resetable).toBeFalsy()

  describe 'Element', ->
    beforeEach ->
      @view = new Backbone.Poised.SubmitControl
        model: @model
        attribute: 'attr'
        cancelable: true
        resetable: true
      $('#jasmine_content').html(@view.render().el)

    describe 'on tap submit', ->
      it 'should trigger submit event', ->
        submitSpy = jasmine.createSpy('submit')
        @view.on('submit', submitSpy)
        @view.$('input.submit').trigger('tap')
        expect(submitSpy).toHaveBeenCalled()

    describe 'on tap cancel', ->
      it 'should trigger cancel event', ->
        cancelSpy = jasmine.createSpy('cancel')
        @view.on('cancel', cancelSpy)
        @view.$('input.cancel').trigger('tap')
        expect(cancelSpy).toHaveBeenCalled()

    describe 'on tap reset', ->
      it 'should trigger reset event', ->
        resetSpy = jasmine.createSpy('reset')
        @view.on('reset', resetSpy)
        @view.$('input.reset').trigger('tap')
        expect(resetSpy).toHaveBeenCalled()
