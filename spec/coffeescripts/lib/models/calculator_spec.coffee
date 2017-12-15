class TestCalculator extends ELA.Models.BaseCalculator
  constructor: (options = {}) ->
    super _.defaults
      required: ['model']
    , options

    @complexCount = 0
    @withTransitiveCount = 0
    @withDirectCount = 0
    @withModelCount = 0

  I_AM_CONSTANT: -1

  complex: @memoize 'complex', ->
    @complexCount += 1
    @withTransitive(5) * @withModel(5) / @withModel(5) * @I_AM_CONSTANT

  withTransitive: @memoize 'withTransitive', (param) ->
    @withTransitiveCount += 1
    @withDirect(param) / 10

  withDirect: @memoize 'withDirect', (param) ->
    @withDirectCount += 1
    @withModel(param) * 10

  withModel: @memoize 'withModel', (param) ->
    @withModelCount += 1
    @model.get('param') + param

  withPole15: (x) -> 1 / (x - 1.5)
  withPole05: (x) -> 1 / (x - 0.5)
  withPole03: (x) -> 1 / (x - 0.3)

describe 'ELA.Models.Calculator', ->
  beforeEach ->
    @model = new Backbone.Model
      param: 5
    @calc = new TestCalculator
      model: @model

  describe 'dependency extraction', ->
    it 'should ignore constants', ->
      expect(@calc.complex.deps).toEqual(['complexCount', 'withTransitive', 'withModel'])

  describe '::memoize', ->
    describe 'extended Calculators', ->
      it 'should resolve model dependencies', ->
        expect(@calc.withModel(5)).toEqual(10)
        expect(@calc.withModel.deps).toEqual(['withModelCount', 'model.param'])

      it 'should resolve dependencies directly', ->
        expect(@calc.withDirect(5)).toEqual(100)
        expect(@calc.withDirect.deps).toEqual(['withDirectCount', 'withModelCount', 'model.param'])

      it 'should resolve dependencies transitively', ->
        expect(@calc.withTransitive(5)).toEqual(10)
        expect(@calc.withTransitive.deps).toEqual(['withTransitiveCount', 'withDirectCount', 'withModelCount', 'model.param'])

      it 'should resolve compact, uniq and flat dependency list', ->
        expect(@calc.complex(5)).toEqual(-10)
        expect(@calc.complex.deps).toEqual(['complexCount', 'withTransitiveCount', 'withDirectCount', 'withModelCount', 'model.param'])

      it 'should trigger change event on model change', ->
        changeComplex = jasmine.createSpy('change:complex')
        @calc.on 'change:complex', changeComplex

        expect(@calc.complex(5)).toEqual(-10)
        @model.set param: 10
        expect(@calc.complex(5)).toEqual(-15)

        expect(changeComplex).toHaveBeenCalled()

      it 'should invoke memoized function only once without changing parameters', ->
        expect(@calc.withModel(5)).toEqual(10)
        expect(@calc.withModelCount).toEqual(1)
        expect(@calc.withModel(5)).toEqual(10)
        expect(@calc.withModelCount).toEqual(1)
        expect(@calc.withDirect(5)).toEqual(100)
        expect(@calc.withDirectCount).toEqual(1)
        expect(@calc.withDirect(5)).toEqual(100)
        expect(@calc.withDirectCount).toEqual(1)
        expect(@calc.withTransitive(5)).toEqual(10)
        expect(@calc.withTransitiveCount).toEqual(1)
        expect(@calc.withTransitive(5)).toEqual(10)
        expect(@calc.withTransitiveCount).toEqual(1)
        expect(@calc.complex()).toEqual(-10)
        expect(@calc.complexCount).toEqual(1)
        expect(@calc.complex()).toEqual(-10)
        expect(@calc.complexCount).toEqual(1)

    it 'should be instance independent', ->
      @model1 = new Backbone.Model param: 5
      @calc1 = new TestCalculator model: @model1
      changeWithModel1 = jasmine.createSpy('change:withModel')
      @calc1.on 'change:withModel', changeWithModel1

      @model2 = new Backbone.Model param: 10
      @calc2 = new TestCalculator model: @model2
      changeWithModel2 = jasmine.createSpy('change:withModel')
      @calc2.on 'change:withModel', changeWithModel2

      expect(@calc1.withModel(5)).toEqual(10)
      expect(@calc1.withModelCount).toEqual(1)
      expect(@calc2.withModel(5)).toEqual(15)
      expect(@calc2.withModelCount).toEqual(1)

      @model1.set param: 20

      expect(@calc1.withModel(5)).toEqual(25)
      expect(@calc1.withModelCount).toEqual(2)
      expect(@calc2.withModel(5)).toEqual(15)
      expect(@calc2.withModelCount).toEqual(1)

      expect(changeWithModel1).toHaveBeenCalled()
      expect(changeWithModel2).not.toHaveBeenCalled()

  describe '#pole', ->
    it 'should find pole at approximately 0.5 with precision 0.01', ->
      x = @calc.pole('withPole05', min: 0, max: 1)
      expectRounded(x).toEqual(0.5)

    it 'should find pole at approximately 0.3 with precision 0.01', ->
      x = @calc.pole('withPole03', min: 0, max: 1)
      expectRounded(x).toEqual(0.2988)

    it 'should return max when pole is out of range', ->
      x = @calc.pole('withPole15', min: 0, max: 1)
      expectRounded(x).toEqual(1)

  describe '#extractDeps', ->
    it 'should extract the correct deps', ->
      func = `function (){var i,maxY,minY,points,pole,x,y,_i,_ref;minY=null;maxY=null;points=[];pole=this.pole("SFC_m2_unlimited");pole=this.func1(this.func2());pole+=this.G()+this.RR()+this.R+this.GG;for(i=_i=0,_ref=this.accuracy;0<=_ref?_i<=_ref:_i>=_ref;i=0<=_ref?++_i:--_i){x=i/this.accuracy*pole;y=this._SFC(2,x);if((minY==null)||y<minY){minY=y}if((maxY==null)||y>maxY){maxY=y}points.push(x,y)}return{points:points,maxY:maxY,minY:minY,tension:this.interpolationTension}}`
      deps = TestCalculator.extractDeps(func)
      expect(deps.sort()).toEqual(['pole', 'func1', 'func2', '_SFC', 'interpolationTension', 'accuracy', 'G', 'RR'].sort())
