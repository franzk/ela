describe 'ELA.Models.Calculator', ->
  describe 'Presenter', ->
    describe 'with `unitFn`', ->
      beforeEach ->
        @curve = new ELA.Models.Curve
          function: 'curve'
          unit: 'km'
          unitFn: (val) -> 3 * val
        @presenter = new @curve.__proto__.Presenter
          model: @curve
          locale: null
          localePrefix: null

      describe '#unitValue', ->
        it 'should return the correct value', ->
          expect(@presenter.unitValue(1000)).toEqual(3000)

    describe 'with `unitFactor`', ->
      beforeEach ->
        @curve = new ELA.Models.Curve
          function: 'curve'
          unit: 'km'
          unitFactor: 0.001
        @presenter = new @curve.__proto__.Presenter
          model: @curve
          locale: null
          localePrefix: null

      describe '#unitValue', ->
        it 'should return the correct value', ->
          expect(@presenter.unitValue(1000)).toEqual(1)
