class Backbone.Poised.BaseControl extends Backbone.Poised.View
  template: _.template('<div class="info"><label><%= label %></label><div class="hint"></div><div class="input"></div></div>')

  initialize: (options = {}) =>
    @initOptions   = options
    throw new Error('Missing `model` option') unless options.model?
    throw new Error('Missing `attribute` option') unless options.attribute?

    @attribute = options.attribute

    @label = options.label

    @options = _.omit(options, 'el')

    if @options.validate
      @model.on 'validated', @hintValidation

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

  render: =>
    @$el.attr('class', "poised control #{@attribute}")
    @$el.html @template
      label: @label or @loadLocale "formFields.#{@attribute}.label",
        defaultValue: @attribute.toLabel()
    @$input = @$el.find('.input')
    this

  clone: (options = {}) =>
    new this.__proto__.constructor(_.defaults(options, @initOptions))
