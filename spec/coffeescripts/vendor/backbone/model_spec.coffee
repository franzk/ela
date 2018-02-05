describe 'Backbone.Model', ->
  describe '#match', ->
    describe 'given a string', ->
      it 'matches only given arguments', ->
        model = new Backbone.Model
          foo: 'bar'
          fu: 'baz'
        expect(model.match('bar', ['foo'])).toBeTruthy()
        expect(model.match('baz', ['foo'])).toBeFalsy()
        expect(model.match('foo')).toBeFalsy()

      it 'matches all attributes without given arguments', ->
        model = new Backbone.Model
          foo: 'bar'
          fu: 'baz'
        expect(model.match('bar')).toBeTruthy()
        expect(model.match('baz')).toBeTruthy()
        expect(model.match('ba')).toBeFalsy()
        expect(model.match('foo')).toBeFalsy()

    describe 'giiven a regular expression', ->
      it 'matches only given arguments', ->
        model = new Backbone.Model
          foo: 'bar boo'
          fu: 'baz'
        expect(model.match(/boo/, ['foo'])).toBeTruthy()
        expect(model.match(/baz/, ['foo'])).toBeFalsy()
        expect(model.match(/foo/, ['foo'])).toBeFalsy()

      it 'matches all attributes without given arguments', ->
        model = new Backbone.Model
          foo: 'bar boo'
          fu: 'baz'
        expect(model.match(/boo/)).toBeTruthy()
        expect(model.match(/baz/)).toBeTruthy()
        expect(model.match(/foo/)).toBeFalsy()
