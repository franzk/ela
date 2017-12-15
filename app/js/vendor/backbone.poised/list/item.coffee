Backbone.Poised.List ||= {}
class Backbone.Poised.List.Item extends Backbone.Poised.View
  tagName: 'li'
  className: 'item'

  template: _.template('<label class="item"></label><div class="buttons"></div>')

  initialize: (options = {}) ->
    super

    @template = options.itemTemplate if options.itemTemplate

    @options = _.pick(options, 'itemLabel')
    if @options.itemLabel and _.isFunction(@options.itemLabel)
      changeTrigger = 'change'
      @options.itemLabel(_.defaults(@labelParameters(), @model.toJSON()))
    else if @options.itemLabel and _.isString(@options.itemLabel)
      changeTrigger = "change:#{@options.itemLabel}"
    else
      changeTrigger = 'change:label change:title change:name'
    @model.on(changeTrigger, @updateLabel)

    @parentView.on 'filter', @filter

  filter: (text, sharedObject) =>
    textChars = text.split('')
    sharedObject.fuzzyRegExp ?= new RegExp(textChars.join('.*'), 'i')
    sharedObject.markRegExps ?= (new RegExp(textChar, 'i') for textChar in textChars)

    if text.length is 0 or sharedObject.fuzzyRegExp.test(@$el.text())
      @$el.css display: ''
    else
      @$el.css display: 'none'
    @renderFilterHint(sharedObject.markRegExps)

  # Querying is emacs-like, just the marking is slightly different,
  # marking every occurence of every character in the query.
  renderFilterHint: (markRegExps) ->
    @$el.removeMark()
    @$el.markRegExp(markRegExp) for markRegExp in markRegExps

  eventFn: (name) =>
    eventName = name
    (e) ->
      @parentView.trigger eventName, @model

  # Stub: Return object to merge into the model attribute objects
  # for the `itemLabel` function.
  #
  # @returns [Object] Values to merge into the model attributes
  labelParameters: -> {}

  updateLabel: =>
    label = if @options.itemLabel and _.isFunction(@options.itemLabel)
      @options.itemLabel(_.defaults(@labelParameters(), @model.toJSON()))
    else if @options.itemLabel and _.isString(@options.itemLabel)
      @model.get(@options.itemLabel)
    else
      @model.get('label') or @model.get('title') or @model.get('name') or 'n/A'
    @$label.html(label)

  render: =>
    @$el.html(@template())
    @$label = @$('label.item')
    @updateLabel()
    @$buttons = @$('.buttons')

    this
