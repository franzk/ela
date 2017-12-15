ELA.Views ?= {}
class ELA.Views.OverviewTile extends Backbone.Poised.List.Item
  tagName: 'li'
  className: 'tile'
  template: JST['overview/tile']

  events:
    'click': 'loadApp'

  loadApp: =>
    if App = ELA[@model.get('name').toCapitalCamel()]?.Models.App
      ELA.router.navigate("app/#{App::path}", trigger: true)
    else
      alert(t('overview.messages.not_implemented'))

  render: =>
    @$el.html @template @model.toJSON()
    this
