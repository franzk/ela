describe 'Poised.Utils', ->
  describe '$.ematch', ->

    describe 'boolean', ->
      it 'should accept true', ->
        expect($.ematch('foo', true)).toBe(true)

      it 'should reject false', ->
        expect($.ematch('foo', false)).toBe(false)

    describe 'regexp', ->
      it 'should accept matching regexp', ->
        expect($.ematch('fou', /fo/)).toBe(true)

      it 'should accept non-matching regexp', ->
        expect($.ematch('foo', /afoo/)).toBe(false)

    describe 'array', ->
      it 'should accept included', ->
        expect($.ematch('foo', ['foo', 'bar'])).toBe(true)
        expect($.ematch('foo', ['fu', 'foo', 'bar'])).toBe(true)

      it 'should reject if not included', ->
        expect($.ematch('foo', ['fu', 'bar'])).toBe(false)
        expect($.ematch('foo', ['fu', 'zaa', 'bar'])).toBe(false)

    describe 'function', ->
      it 'should run it with string as first argument', (done) ->
        $.ematch 'foo', (s) ->
          expect(s).toEqual('foo')
          done()

      it 'should run it with proper context', (done) ->
        $.ematch 'foo', (s) ->
          expect(this).toEqual('foo')
          done()

      it 'should evaluate return value', ->
        expect($.ematch('foo', -> true)).toBe(true)
        expect($.ematch('foo', -> false)).toBe(false)

    it 'should refuse invalid expression', ->
      expect($.ematch('foo', {})).toBe(false)
      expect($.ematch('foo')).toBe(false)
      expect($.ematch('foo', null)).toBe(false)
