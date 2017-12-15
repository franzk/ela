class Backbone.Poised.SubmitControl extends Backbone.Poised.View
  tagName: 'ul'
  className: 'poised button-group'

  events:
    'tap input.submit': 'submitTapped'
    'tap input.cancel': 'cancelTapped'
    'tap input.reset': 'resetTapped'

  initialize: (options = {}) ->
    super

    @options = _.chain(options)
      .pick('cancelable', 'resetable')
      .defaults
        cancelable: false
        resetable: false
      .value()

  submitTapped: (e) =>
    @trigger('submit')
    e.preventDefault()

  cancelTapped: (e) =>
    @trigger('cancel')
    e.preventDefault()

  resetTapped: (e) =>
    @trigger('reset')
    e.preventDefault()

  render: =>
    @$el.html()
    @$el.append('<li><input class="poised button primary submit" type="submit" value="Save"></li>')
    if @options.cancelable
      @$el.append('<li><input class="poised button secondary cancel" type="submit" value="Cancel"></li>')
    if @options.resetable
      @$el.append('<li><input class="poised button secondary reset" type="submit" value="Reset"></li>')
    this
