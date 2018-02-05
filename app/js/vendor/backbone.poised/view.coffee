Backbone.Poised ||= {}
class Backbone.Poised.View extends Backbone.View
  constructor: (options = {}) ->
    @__arguments__ = Array.prototype.slice(arguments, 0)

    @locale = options.locale
    @localePrefix = options.localePrefix

    @parentView = options.parentView if options?.parentView?
    super
    @subviews = {}
    @on 'all', =>
      if @parentView?
        @parentView.trigger.apply(@parentView, arguments)

  # Loads the locales according to `@locale` and `@localePrefix`
  # functions.
  #
  # TODO: Extend this docstring with some examples.
  #
  # @param [String...] keys Keys that are used to contruct #t keys
  # @param [Object] options Options passed to #t
  #
  # @returns First found locale
  loadLocale: (args...) ->
    options = if _.isObject(_.last(args)) then args.pop() else {}
    keys = args
    locales = []
    if _.isArray(@locale)
      locales.push(locale) for locale in @locale
    if _.isString(@locale)
      locales.push(@locale)
    for key in keys
      if _.isArray(@localePrefix)
        for prefix in @localePrefix
          locales.push("#{prefix}.#{key}")
        locales
      if _.isString(@localePrefix)
        locales.push("#{@localePrefix}.#{key}")
      locales.push(key)
    t(locales..., options)

  # Creates a Presenter instance for given model instance.
  # Memoizes the presenter after instantiation.
  #
  # TODO: Extend this docstring with some examples.
  #
  # @param [Object] model The model to find a ViewModel for
  #
  # @returns [Backbone.Poised.View] presenter The Presenter object
  Present: (model) ->
    model._presenter ?= new (model.__proto__.Presenter or Backbone.Poised.View)
      model: model
      locale: @locale
      localePrefix: @localePrefix

  remove: =>
    _.invoke(@subviews, 'remove')
    super
