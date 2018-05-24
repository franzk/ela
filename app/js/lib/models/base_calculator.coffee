ELA.Models ?= {}
class ELA.Models.BaseCalculator
  _.extend @prototype, Backbone.Events

  xRange: (func) -> 1.0
  yRange: (func) ->
    curve = func
    group = _.find @curveGroups, (group) -> _.contains(group, curve)
    minY = null
    maxY = null
    if group?
      for func in group when _.isFunction(@[func])
        result = @[func]()
        maxY = Math.max(result.maxY, maxY)
        minY = Math.min(result.minY, minY)
    else
      result = null
      if _.isFunction(@[func])
        result = @[func]()
      else
        throw new Error("#{func} does not specify a calculator function in #{name}")
      minY = result.minY
      maxY = result.maxY

    range = 0
    range += maxY if maxY > 0
    range -= minY if minY < 0
    range

  constructor: (options) ->
    for required in (options.required or [])
      throw "Missing `#{required}` option" unless options[required]?

    models = _.omit(options, 'required')

    @_memo = {}

    this[name] = model for name, model of models

    @bindEvents(models)

  bindEvents: (models = {}) ->
    @stopListening()
    for key, obj of models
      do =>
        if obj.on?
          modelName = _.clone(key)
          @listenTo obj, 'change', (model) =>
            for attribute, value of model.changed
              @trigger("change:#{modelName}.#{attribute}", model, value)

  @_parseForDeps: (funcStr) ->
    for dep in (funcStr.match(/this.([$_a-zA-Z][$_a-zA-Z0-9]*(\.get)?(\([^\)]*\))?)/g) or [])
      dep = dep.slice(5)
      continue if /^[_A-Z][_A-Z0-9]*$/.test(dep) # skip CONSTANTS
      if (match = dep.match(/([^.]+)\.get\(['"]([^'"]+)['"]\)/))
        "#{match[1]}.#{match[2]}"
      else
        ampIndex = dep.indexOf('(')
        if ampIndex > 0
          # Search within parentheses again
          [dep.slice(0, ampIndex), @_parseForDeps(dep.slice(ampIndex))]
        else
          dep

  @extractDeps: (func) ->
    deps = @_parseForDeps(func.toString())
    _.chain(deps).flatten().compact().uniq().value()

  @memoize: (name, func) ->
    resolveDeps = (f) ->
      depsBefore = ''
      until f.deps.join('') is depsBefore
        depsBefore = f.deps.join('')
        f.deps = for dep in f.deps
          if /([^.]+)\.([^.]+)/.test(dep)
            dep
          else if this[dep]?
            this[dep].deps or dep
        f.deps = _.chain(f.deps).flatten().compact().uniq().value()
      f.depsResolved = true

    bindDeps = (f, callback) ->
      for dep in f.deps
        @on "change:#{dep}", =>
          callback.call(this)
          @trigger("change:#{name}")
      @_memo[name].eventsBound = true

    parameters = do ->
      funcStr = func.toString()
      if (match = funcStr.match(/^function ?\(([^\)]+)\)/))?
        match[1].split(',')
      else
        []

    # TODO: Bind Events for dynamic dependencies like this[func] where
    # func is a string parameter when calling the function.
    f = if parameters.length > 0
      ->
        @_memo[name] ?= values: {}, eventsBound: false
        key = JSON.stringify(arguments)

        unless @_memo[name].values[key]?
          @_memo[name].values[key] = func.apply(this, arguments)

        resolveDeps.call(this, f) unless f.depsResolved

        unless @_memo[name].eventsBound
          bindDeps.call this, f, ->
            @_memo[name].values = {}

        @_memo[name].values[key]

    else
      ->
        @_memo[name] ?= eventsBound: false

        unless @_memo[name].value?
          @_memo[name].value = func.apply(this, arguments)

        resolveDeps.call(this, f) unless f.depsResolved

        unless @_memo[name].eventsBound
          bindDeps.call this, f, ->
            @_memo[name].value = null

        @_memo[name].value

    f.depsResolved = false
    f.memoizable = true
    f.deps = @extractDeps(func)
    f

  @reactive: (name, func) ->
    resolveDeps = (f) ->
      depsBefore = ''
      resolvedDeps = [] # required to avoid loops
      until f.deps.join('') is depsBefore
        depsBefore = f.deps.join('')
        f.deps = for dep in f.deps
          continue if dep is name
          if /([^.]+)\.([^.]+)/.test(dep)
            dep
          else if this[dep]? and not _.contains(resolvedDeps, dep)
            resolvedDeps.push(dep)
            this[dep].deps or dep
        f.deps = _.chain(f.deps).flatten().compact().uniq().value()
      f.depsResolved = true

    bindDeps = (f, callback) ->
      for dep in f.deps
        @on "change:#{dep}", =>
          callback() if callback?
          @trigger("change:#{name}")
      @_memo[name].eventsBound = true

    parameters = do ->
      funcStr = func.toString()
      if (match = funcStr.match(/function \(([^\)]+)\)/))?
        match[1].split(',')
      else
        []

    # TODO: Bind Events for dynamic dependencies like this[func] where
    # func is a string parameter when calling the function.
    f = ->
      @_memo[name] ||= eventsBound: false
      resolveDeps.call(this, f) unless f.depsResolved
      bindDeps.call(this, f) unless @_memo[name].eventsBound
      f._func.apply(this, arguments)

    f.depsResolved = false
    f.memoizable = false
    f.deps = @extractDeps(func)
    f._func = func
    f

  clearMemoizations: ->
    for key, memo of @_memo
      memo.value = null if _.has(memo, 'value')
      memo.values = {} if _.has(memo, 'values')

  pole: (func, options = {}) ->
    precision = Math.abs(options.precision or 0.001)
    min       = options.min or 0.0
    max       = options.max or 1.0
    middle    = (max + min)*0.5

    minPos    = this[func](min)    > 0
    maxPos    = this[func](max)    > 0
    middlePos = this[func](middle) > 0

    n = 0
    if minPos is maxPos
      return max
    else
      while middle - min > precision
        y = this[func](middle)
        return middle if y is Infinity or y is -Infinity

        if minPos is middlePos
          min = middle
          minPos = middlePos
        else
          max = middle
          maxPos = middlePos

        middle = (max + min)*0.5
        middlePos = this[func](middle) > 0
        n += 1
    min
