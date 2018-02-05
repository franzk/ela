describe 'Backbone.Poised.View', ->
  beforeEach ->
    @view = new Backbone.Poised.View()
    @subview = @view.subviews.testView = new Backbone.Poised.View
      parentView: @view

  it 'should have subviews object', ->
    expect(@view.subviews).toBeObject()

  it 'should remove subviews correctly', ->
    spyOn(@subview, 'remove')
    @view.remove()
    expect(@subview.remove).toHaveBeenCalled();

  it 'should set the subviews parentView', ->
    expect(@subview.parentView).toEqual(@view)

  it 'should bubble events to their parent view', ->
    parentCallback = jasmine.createSpy('someEvent')
    @view.on 'someEvent', parentCallback
    @subview.trigger('someEvent', 'someParameter')
    expect(parentCallback).toHaveBeenCalledWith('someParameter')

  describe '#loadLocale', ->
    beforeEach ->
      ELA.labels = flattenObject
        fallback: 'Fallback'
        locale: 'Root Locale'
        locale2: 'Other Root Locale'
        some:
          locale: 'Some Locale'
          locale2: 'Some Other Locale'
          prefix:
            locale: 'Some Prefix Locale'
            locale2: 'Some Other Prefix Locale'

    describe 'with locale string', ->
      beforeEach ->

      it 'should return the locale', ->
        view = new Backbone.Poised.View
          locale: 'some.locale'
        expect(view.loadLocale('locale')).toEqual('Some Locale')

      it 'should return the fallback', ->
        view = new Backbone.Poised.View
          locale: 'some.non-existing-locale'
        expect(view.loadLocale('fallback')).toEqual('Fallback')

    describe 'with locale array', ->
      it 'should return the primary', ->
        view = new Backbone.Poised.View
          locale: ['some.locale', 'locale']
        expect(view.loadLocale('fallback')).toEqual('Some Locale')

      it 'should return the secondary', ->
        view = new Backbone.Poised.View
          locale: ['some.non-existing-locale', 'locale']
        expect(view.loadLocale('fallback')).toEqual('Root Locale')

      it 'should return the fallback', ->
        view = new Backbone.Poised.View
          locale: ['some.non-existing-locale', 'non-existing-locale']
        expect(view.loadLocale('fallback')).toEqual('Fallback')

    describe 'with localePrefix string', ->
      it 'should return the prefixed locale', ->
        view = new Backbone.Poised.View
          localePrefix: 'some.prefix'
        expect(view.loadLocale('locale')).toEqual('Some Prefix Locale')

      it 'should return the root locale', ->
        view = new Backbone.Poised.View
          localePrefix: 'some.non-existing-prefix'
        expect(view.loadLocale('locale')).toEqual('Root Locale')

      describe 'given multiple locale keys', ->
        it 'should return the primary locale', ->
          view = new Backbone.Poised.View
            localePrefix: 'some.prefix'
          expect(view.loadLocale('locale', 'locale2')).toEqual('Some Prefix Locale')

        it 'should return the primary prefixed other locale', ->
          view = new Backbone.Poised.View
            localePrefix: 'some.prefix'
          expect(view.loadLocale('non-existing-locale', 'locale2')).toEqual('Some Other Prefix Locale')

        it 'should return the primary prefixed other locale', ->
          view = new Backbone.Poised.View
            localePrefix: 'some.non-existing-prefix'
          expect(view.loadLocale('non-existing-locale', 'locale2')).toEqual('Other Root Locale')

    describe 'with localePrefix array', ->
      it 'should return the primary prefixed locale', ->
        view = new Backbone.Poised.View
          localePrefix: ['some.prefix', 'some']
        expect(view.loadLocale('locale')).toEqual('Some Prefix Locale')

      it 'should return the secondary prefixed locale', ->
        view = new Backbone.Poised.View
          localePrefix: ['some.non-existing-prefix', 'some']
        expect(view.loadLocale('locale')).toEqual('Some Locale')

      it 'should return the root locale', ->
        view = new Backbone.Poised.View
          localePrefix: ['some.non-existing-prefix', 'some']
        expect(view.loadLocale('locale')).toEqual('Some Locale')

      describe 'given multiple locale keys', ->
        it 'should return the primary locale', ->
          view = new Backbone.Poised.View
            localePrefix: ['some.prefix', 'some']
          expect(view.loadLocale('locale', 'locale2')).toEqual('Some Prefix Locale')

        it 'should return the primary prefixed other locale', ->
          view = new Backbone.Poised.View
            localePrefix: ['some.prefix', 'some']
          expect(view.loadLocale('non-existing-locale', 'locale2')).toEqual('Some Other Prefix Locale')

        it 'should return the primary prefixed other locale', ->
          view = new Backbone.Poised.View
            localePrefix: ['some.non-existing-prefix', 'some']
          expect(view.loadLocale('non-existing-locale', 'locale2')).toEqual('Some Other Locale')
