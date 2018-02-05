class Backbone.Poised.LinkedControl extends Backbone.Poised.View
  template: _.template("<div class=\"info\"><label><%= label %></label></div><div class=\"first control\"><div class=\"hint\"></div></div><div class=\"link icon\"></div><div class=\"second control\"><div class=\"hint\"></div></div>")

  events:
    'tap .link.icon': 'toggleLinkState'

  initialize: (options = {}) ->
    @initOptions   = options
    throw new Error('Missing `model1` option') unless options.model1?
    throw new Error('Missing `model2` option') unless options.model2?
    throw new Error('Missing `attribute` option') unless options.attribute?

    @attribute = options.attribute
    @model1 = options.model1
    @model2 = options.model2

    @label = options.label

    @stateDefaults = _.chain(options)
      .pick('isLinked')
      .defaults
        isLinked: true
      .value()

    @listenTo @model1, 'validated', @hintValidation if options.validate?

    @listenTo @model1, "change:#{@attribute}", @updateLinkedAttribute(@model2)
    @listenTo @model2, "change:#{@attribute}", @updateLinkedAttribute(@model1)

    @linkState = new Backbone.Model(@stateDefaults)
    @linkState.on 'change:isLinked', @updateLinkIcon

    @on 'liveChangeStart', =>
      @parentView.trigger('controlLiveChangeStart', this) if @parentView?
    @on 'liveChange', =>
      @parentView.trigger('controlLiveChange', this) if @parentView?
    @on 'liveChangeEnd', =>
      @parentView.trigger('controlLiveChangeEnd', this) if @parentView?

  hintValidation: (isValid, model, errors) =>
    attributeValid = @model.isValid(@attribute)
    if errors isnt @lastErrors
      @$el.toggleClass('invalid', !attributeValid)
      @$hint = @$('.hint')
      @$hint.attr 'data-error': errors[@attribute]
    @lastErrors = errors

  isLinked: ->
    @linkState.get('isLinked')

  toggleLinkState: =>
    @linkState.set(isLinked: !@isLinked())

  updateLinkedAttribute: (linkedModel) ->
    (model, value) =>
      linkedModel.set(@attribute, value) if @isLinked()

  updateLinkIcon: =>
    @$link?.toggleClass('unlinked', !@isLinked())

  render: =>
    @$el.attr('class', "poised linked-control #{@attribute}")
    @$el.html @template
      label: @label or @loadLocale "formFields.#{@attribute}.label",
        defaultValue: @attribute.toLabel()
    @$link = @$('.link.icon')
    @$control1 = @$('.first.control')
    @$control1.toggleClass(@attribute)
    @$control2 = @$('.second.control')
    @$control2.toggleClass(@attribute)
    @updateLinkIcon()
    this

  clone: (options = {}) =>
    options = _.chain(options)
      .defaults isLinked: @isLinked()
      .defaults @initOptions
      .value()
    new @__proto__.constructor(options)
