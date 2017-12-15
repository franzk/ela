Backbone.Poised ||= {}
class Backbone.Poised.Form extends Backbone.Poised.View
  tagName: 'form'
  className: 'poised'

  events:
    'submit': 'preventOriginalSubmit'

  preventOriginalSubmit: (e) -> e.preventDefault()

  extractGroupOptions: (options = {}) ->
    @options.group = _.chain(options)
      .pick('by', 'collapsible', 'collapsed')
      .defaults
        collapsible: false
        collapsed: []
      .value()

  extractOptions: (options = {}) ->
    # TODO: Maybe default titles should use the name of the model or
    # the localisation for models...
    @options = _.chain(options)
      .pick('cancelable', 'resetable', 'title', 'creationTitle', 'editingTitle', 'liveForm', 'validate')
      .defaults
        cancelable: false
        resetable: false
        liveForm: false
        validate: @model.__proto__.validation?
      .value()

    @extractGroupOptions(options.group)

  extractFields: (options = {}) ->
    if options.fields
      @fields = options.fields
    else if @model.formFields?
      @fields = @model.formFields
    else
      @fields = []

  initialize: (options = {}) ->
    throw new Error('Missing `model` option') unless options.model?

    @extractOptions(options)
    @extractFields(options)

  validateSubmit: =>
    errors = @model.validate()
    if _.isEmpty(errors)
      @trigger('validSubmit', @model)
    else
      @trigger('invalidSubmit', @model)
      # Refocus the first invalid input control, causing the browser to
      # scroll to this element automatically.
      @$('.invalid input').first().blur()
      @$('.invalid input').first().focus()

  submit: =>
    @trigger('submit', @model)
    @validateSubmit() if @options.validate

  cancel: =>
    @trigger('cancel', @model)

  appendGroup: (group, fields) =>
    $grp = $('<div>', class: 'poised control-group')
    @appendItem(field, $grp) for field in fields
    @$el.append($grp)

  appendItem: (field, $el = @$el) =>
    # Make sure we do not override defaults by cloning the field defaults
    f = _.clone(field)

    f.type = 'anchor' if f.anchor?
    f.type = 'range' if f.range?
    f.type = 'select' if f.options?
    f.type ||= 'text'

    f.locale = @locale
    f.localePrefix = @localePrefix

    @subviews[f.attribute] = @controlView(f)

    $el.append(@subviews[f.attribute].render().el)

  # Instantiates the correct form control view for the given field
  # object. Eventually sets default values for needed options (e.g.
  # models, the parent view, etc.) and sets the correct validation
  # function.
  #
  # @param [Object] field The field
  #
  # @returns [Backbone.Poised.LinkedControl] view The view for the control
  controlView: (field) ->
    field = _.defaults field,
      model: @model
      parentView: this
    field.validate = @model.__proto__.validation and _.has(@model.__proto__.validation, field.attribute)
    switch field.type
      when 'text' then new Backbone.Poised.StringControl(field)
      when 'range' then new Backbone.Poised.RangeControl(field)
      when 'number' then new Backbone.Poised.NumberControl(field)
      when 'select' then new Backbone.Poised.SelectControl(field)
      when 'value' then new Backbone.Poised.ValueControl(field)
      when 'anchor' then new Backbone.Poised.Anchor(field)

  # Binds Backbone.Validations to the respective view and model.
  bindValidation: ->
    Backbone.Validation.bind(this) if @options.validate

  # Returns the string for the title in the form template.
  # If a localisation exists, this is used.
  title: ->
    if @model.isNew()
      @loadLocale 'formTitles.create', 'formTitle',
        defaultValue: @options.creationTitle or @options.title
        returnNull: true
    else
      @loadLocale 'formTitles.edit', 'formTitle',
        defaultValue: @options.editingTitle or @options.title
        returnNull: true

  render: =>
    @$el.html()

    title = @title()
    @$el.append($('<h2 />', text: title)) if title

    if @options.group.by
      groups = _.chain(@fields)
        .pluck(@options.group.by)
        .compact()
        .unique()
        .value()
      for group in groups
        @appendItem
          type: 'anchor'
          anchor: group.toCamel()
          collapsible: $.ematch(group, @options.group.collapsible)
          collapsed: $.ematch(group, @options.group.collapsed)
        @appendGroup(group, _.filter(@fields, (f) => f[@options.group.by] is group))
    else
      @appendItem(field) for field in @fields

    unless @options.liveForm
      @subviews.buttons = new Backbone.Poised.SubmitControl
        parentView: this
        cancelable: @options.cancelable
        resetable: @options.resetable
      @listenTo @subviews.buttons, 'submit', @submit
      @listenTo @subviews.buttons, 'cancel', @cancel
      @$el.append(@subviews.buttons.render().el)

    @bindValidation()

    this
