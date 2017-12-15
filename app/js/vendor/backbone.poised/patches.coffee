Backbone.Model::match = (test, keys = null) ->
  values = if keys? and keys isnt true then _.values(@pick.apply(this, keys)) else @values()
  if _.isRegExp(test)
    _.some values, (attr) -> test.test(attr)
  else
    _.some values, (attr) -> attr == test
