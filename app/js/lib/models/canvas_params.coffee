ELA.Models ?= {}
class ELA.Models.CanvasParams extends Backbone.Model
  serialize: -> {}
  deserialize: ->

  constructor: (attributes, options) ->
    @app = attributes.app
    delete attributes.app
    # Special behavior: initial attributes overwrite defaults
    @defaults = _.defaults(attributes, _.clone(@defaults))
    super({}, options)
