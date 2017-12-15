Backbone.Poised.List ||= {}
class Backbone.Poised.List.Searchfield extends Backbone.Poised.View
  tagName: 'li'
  className: 'search-box'

  template: _.template("<input type='search' placeholder='<%= placeholder %>'>")

  initialize: (options = {}) ->
    super

    @options = _.chain(options)
      .pick('placeholder')
      .value()

  events:
    'input input': 'filterList'

  filterList: (e) =>
    clearTimeout @filterInputTimeout
    @filterInputTimeout = delay 250, =>
      @trigger('filter', $(e.target).val() or '', {})

  render: =>
    placeholder = @options.placeholder or @loadLocale('search.placeholder')
    @$el.html @template placeholder: placeholder
    this
