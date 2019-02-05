ELA.Collections ?= {}
class ELA.Collections.LimitedCollection extends Backbone.Collection
  attribute: 'selected'
  limit: 0
  activeState: true

  constructor: (args..., options = {}) ->
    super
    @limit = options.limit if options.limit?
    @attribute = options.attribute if options.attribute?
    @activeState = options.activeState if options.activeState?
    @history = []
    @on "change:#{@attribute}", @manageHistory
    @on('add', @manageHistory)
    @on('remove', @removeFromHistory)
    @on('reset', @rebuildHistory)
    @rebuildHistory()

  # Returns the history in the selection order.
  #
  # @returns [Array] Models in the selection order
  getHistory: ->
    @history

  # Returns the history in the collection order.
  #
  # @returns [Array] Models in the selection order
  whereInHistory: ->
    filter = {}
    filter[@attribute] = @activeState
    @where(filter)

  # Returns the oldest model in history.
  #
  # @returns [Backbone.Model] The oldest model
  getOldest: ->
    @history[0]

  # Returns `true` if the history limit is reached.
  #
  # @returns [Boolean] Whether history limit is reached
  atLimit: ->
    @history.length >= @limit if @limit > 0

  # Returns `true` if given model is in history.
  #
  # @param [Backbone.Model] model The model to check for
  #
  # @returns [Boolean] Whether model is in history
  inHistory: (model) ->
    @history.indexOf(model) isnt -1

  # Removes all occurences of given model from histroy.
  #
  # @param [Backbone.Model] model Model to remove
  removeFromHistory: (model) ->
    while @inHistory(model)
      @history.splice(@history.indexOf(model), 1)
      @trigger('historyRemove')

  # Rebuilds history leaving old history entries untouched. Entries
  # are being added in collection order.
  rebuildHistory: ->
    oldHistory = _.clone(@history)
    @history = []
    @each (model) =>
      @manageHistory(model, silent: true)
    unless _.isEqual(oldHistory, @history)
      @trigger('historyReset')

  # Whenever a model is changing its `activeState` the history is
  # checked. If the model is `activated` and the history is at its
  # limit the oldest model in the history gets deactivated.
  #
  # @param [Backbone.Model] model The model of the state change
  manageHistory: (model, options = {}) ->
    if model.get(@attribute) is @activeState
      if !@inHistory(model)
        while @atLimit()
          @history.shift().set(@attribute, not @activeState)
        @history.push(model)
        @trigger('historyAdd') unless options.silent
    else
      @removeFromHistory(model)
    this
