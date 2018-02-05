ELA.Collections ?= {}
class ELA.Collections.NamedObjectCollection extends Backbone.Collection
  constructor: (models) ->
    if typeof models is 'object'
      models = for name, attributes of models
        $.extend(attributes, name: name)
    super
