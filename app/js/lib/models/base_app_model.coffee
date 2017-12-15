ELA.Models ?= {}
class ELA.Models.BaseAppModel extends Backbone.Model
  # Returns the locale prefixes for the current app. Subapps have all
  # levels as prefix.
  localePrefix: (append = null) ->
    prefixes = []
    path = @path.split('/')
    path.push(append) if append?
    until path.length < 1
      prefixes.push(path.join('.'))
      path.pop()
    if prefixes.length <= 0
      null
    else if prefixes.length is 1
      prefixes[0]
    else
      prefixes

  # Loads the settings for the current app. This function is subapp
  # aware meaning it prefers the current subapps settings, then the
  # parent apps settings.
  #
  # @param [String] type the settings type (e.g. curves, formFields, defaults, etc.)
  # @param [String] key the settings key (may be undefined)
  # @param [Object] defaults the fixed defaults (those may not be overwritten)
  # @returns [Object] the merged settings
  loadSettings: (type, key, defaults = {}) ->
    @settings ||= {}
    settings = @settings["#{type}_#{key}"] ||= do =>
      settings = {}
      pathComponents = @path.split('/')
      until pathComponents.length < 1
        step = ELA.settings
        step = step[component] for component in pathComponents when step?
        if type? and key?
          settings = $.extend step?[type]?[key], settings
        else
          settings = $.extend step?[type], settings
        pathComponents.pop()
      settings
    $.extend settings, defaults

  # Loads the default parameters for the current app.
  defaults: ->
    @loadSettings('defaults')

  # Loads the settings for a specific form field.
  #
  # @param [String] attribute the name of the attribute
  # @param [Object] defaults
  loadFormFieldSettings: (attribute, defaults = {}) ->
    defaults.attribute = attribute
    @loadSettings('formFields', attribute, defaults)

  # Loads the curve settings for given FUN for the current app.
  #
  # @param [String] fun name of the curve function
  # @param [Object] defaults default values
  loadCurveSettings: (fun, defaults = {}) ->
    defaults.function = fun
    @loadSettings('curves', fun, defaults)
