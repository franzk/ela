class TestApp extends ELA.Models.BaseAppModel
  name: 'someTestApp'
  path: 'someTestApp/deep/path'

describe 'ELA.Models.BaseAppModel', ->
  beforeEach ->
    ELA.settings =
      someTestApp:
        defaults:
          testField1: 50
          testField2: 0.5
        curves:
          testCurve:
            group: 'someTestGroup'
        formFields:
          testField1:
            range: [0, 100]
            unit: 'km'
          testField2:
            range: [0, 1]
            stepSize: 0.01
        deep:
          defaults:
            testField2: 0.8
          curves:
            testCurve:
              lineWidth: 1
          path:
            curves:
              testCurve:
                lineWidth: 2
            formFields:
              testField1:
                range: [0, 200]
                stepSize: 0.1
    @app = new TestApp()


  describe 'subclass', ->
    describe '#localePrefix', ->
      it 'should return correct array', ->
        expect(@app.localePrefix()).toEqual [
          'someTestApp.deep.path'
          'someTestApp.deep'
          'someTestApp'
        ]

      it 'should append array', ->
        expect(@app.localePrefix('append')).toEqual [
          'someTestApp.deep.path.append'
          'someTestApp.deep.path'
          'someTestApp.deep'
          'someTestApp'
        ]

    describe '#defaults', ->
      it 'should load defaults correctly', ->
        expect(@app.defaults()).toEqual
          testField1: 50
          testField2: 0.8

    describe '#loadFormFieldSettings', ->
      it 'should overwrite with given defaults', ->
        settings = @app.loadFormFieldSettings('testField1', stepSize: 5)
        expect(settings).toEqual
          attribute: 'testField1'
          range: [0, 200]
          stepSize: 5
          unit: 'km'

      it 'should use overwrite settings accordingly', ->
        settingsTestField1 = @app.loadFormFieldSettings('testField1')
        expect(settingsTestField1).toEqual
          attribute: 'testField1'
          range: [0, 200]
          stepSize: 0.1
          unit: 'km'
        settingsTestField2 = @app.loadFormFieldSettings('testField2')
        expect(settingsTestField2).toEqual
          attribute: 'testField2'
          range: [0, 1]
          stepSize: 0.01

      it 'should memoize and return the same value', ->
        val1 = @app.loadFormFieldSettings('testField1')
        val2 = @app.loadFormFieldSettings('testField1')
        expect(val1).toEqual(val2)

    describe '#loadCurveSettings', ->
      it 'should overwrite with given defaults', ->
        settings = @app.loadCurveSettings('testCurve', lineWidth: 5)
        expect(settings).toEqual
          function: 'testCurve'
          group: 'someTestGroup'
          lineWidth: 5

      it 'should use overwrite settings accordingly', ->
        settings = @app.loadCurveSettings('testCurve')
        expect(settings).toEqual
          function: 'testCurve'
          group: 'someTestGroup'
          lineWidth: 2

      it 'should memoize and return the same value', ->
        val1 = @app.loadCurveSettings('testCurve')
        val2 = @app.loadCurveSettings('testCurve')
        expect(val1).toEqual(val2)
