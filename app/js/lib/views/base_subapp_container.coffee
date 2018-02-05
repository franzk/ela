ELA.Views ?= {}
class ELA.Views.BaseSubappContainer extends Backbone.Poised.View
  id: -> @model.name.toDash()
  tagName: 'section'
  className: 'subapp-container'
  subappViews: []

  events:
    'tap header h2': 'switchSubapp'

  initialize: ->
    super
    @listenTo @model, 'change:path', @toggleActivation

  remove: =>
    @$el.afterTransitionForRemovingClass 'active', => super

  setActive: (active) =>
    @$el.toggleClass('active', active)

  activate: =>
    @$el.toggleClass('active', true)

  deactivate: =>
    @$el.toggleClass('active', false)

  toggleActivation: =>
    subapp = @model.get('path')[0]
    for name, app of @model.subapps
      @subviews[name].setActive(name is subapp)

  render: =>
    @$el.empty()

    for name, app of @model.subapps
      SubappView = app.view.toFunction()
      @subviews[name] = view = new SubappView
        model: @model.subappInstances[name]
        localePrefix: "#{@localePrefix}.#{name}"
      @$el.append(view.render().el)

    @toggleActivation()

    this
