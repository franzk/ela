class Backbone.Poised.Selectbox extends Backbone.Poised.View
  className: 'poised selectbox'

  events:
    'change select': 'changeAttributeValue'

  initialize: (options = {}) =>
    throw new Error('Missing `model` option') unless options.model?
    throw new Error('Missing `attribute` option') unless options.attribute?

    @attribute = options.attribute

    @options = _.chain(options)
      .pick('placeholder', 'options', 'multiselect', 'validate')
      .defaults
        options: []
        multiselect: false
        validate: true
      .value()
    unless @options.placeholder?
      @options.placeholder = not @options.multiselect and not @model.get(@attribute)?
    @options.placeholder = 'Please select ...' if @options.placeholder is true

    @model.on("change:#{@attribute}", @updateSelectedOption)

  changeAttributeValue: =>
    if @options.multiselect
      options = for option in @$select.find('option:selected')
        $(option).data('value')
    else
      options = @$select.find('option:selected').data('value')
    @model.set(@attribute, options)

  updateSelectedOption: (model, value) =>
    selectedValues = _.compact(_.flatten(
      [value or @model.get(@attribute)]
    ))
    for option, idx in @$select.find('option')
      $option = $(option)
      if @options.placeholder and _.isEmpty(selectedValues)
        isSelected = idx is 0
      else
        isSelected = _.contains(selectedValues, $option.data('value'))
      $option.attr(selected: isSelected)

  render: =>
    @$select = $ '<select />',
      class: 'poised'
      name: @attribute
      multiple: @options.multiselect

    if @options.placeholder
      @$select.append $ '<option>',
        text: @loadLocale(
          "formFields.#{@attribute}.options.placeholder"
          "formFields.selectPlaceholder"
          "generic.selectPlaceholder"
          defaultValue: @options.placeholder
        )
        disabled: true

    if _.isFunction(@options.options)
      options = @options.options.apply(@model)
    else
      options = @options.options
    if _.isArray(options)
      options = _.object(options, options)
    for label, option of options
      @$select.append $ '<option>',
        data:
          value: option
        text: @loadLocale "formFields.#{@attribute}.options.#{label}",
          defaultValue: label

    @$el.html(@$select)

    @updateSelectedOption()
    this
