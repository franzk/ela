Backbone.Poised ||= {}
class Backbone.Poised.LinkedForm extends Backbone.Poised.Form
  tagName: 'form'
  className: 'poised'

  initialize: (options = {}) ->
    throw new Error('Missing `model1` option') unless options.model1?
    throw new Error('Missing `model2` option') unless options.model2?

    # as reference model and for validations
    @model  = options.model1

    @model1 = options.model1
    @model2 = options.model2

    @extractOptions(options)
    @extractFields(options)

  # Bind validations of both models to this view.
  bindValidation: ->
    Backbone.Validation.bind(this, model: @model1)
    Backbone.Validation.bind(this, model: @model2)

  # Instantiates the linked control view for the given field object.
  # Eventually sets the default values for needed options (e.g.
  # models, the parent view, etc.) and sets the correct validation
  # function.
  #
  # @see [Backbone.Poised.Form#controlView]
  #
  # @returns [Backbone.Poised.LinkedControl] view The view for the control
  controlView: (field) ->
    field = _.defaults field,
      model1: @model1
      model2: @model2
      parentView: this
    field.validate = @model1.__proto__.validation and _.has(@model1.__proto__.validation, field.attribute)
    switch field.type
      when 'text' then new Backbone.Poised.LinkedStringControl(field)
      when 'range' then new Backbone.Poised.LinkedRangeControl(field)
      when 'number' then new Backbone.Poised.LinkedNumberControl(field)
      when 'select' then new Backbone.Poised.LinkedSelectControl(field)
      when 'anchor' then new Backbone.Poised.Anchor(field)
