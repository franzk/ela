_.firstDefined = (args...) ->
  _.without(args, undefined, null)[0]
