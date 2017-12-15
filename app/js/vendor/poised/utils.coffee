$.ematch = (val, expr) ->
  if typeof expr is 'boolean'
    expr
  else if expr?.constructor.name is 'RegExp'
    expr.test(val)
  else if $.isArray(expr)
    $.inArray(val, expr) > -1
  else if typeof expr is 'function'
    expr.call(val, val)
  else
    false
