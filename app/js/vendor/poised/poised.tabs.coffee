$.poised = {}
$.poised.tabs = (element, options) ->
  plugin = this
  plugin.settings = {}
  $element = $(element)
  element = element

  plugin.init = ->
    $header = $element.find('header ')
    $headerTabs = $header.find('.tab')

    updateActiveTab = (active) ->
      active ||= $element.find('.tab-content.active').attr('data-tab') || $element.find('.tab-content').first().attr('data-tab')
      $element.find('.tab, .tab-content').each (elem) ->
        $el = $(this)
        id = $el.attr('data-tab-view') || $el.attr('data-tab')
        $el.toggleClass('active', id == active)
      $activeTab = $header.find("[data-tab-view=#{active}]")

    $headerTabs.on 'tap', (e) ->
      updateActiveTab($(e.target).attr('data-tab-view'))
    updateActiveTab()

  plugin.init()

$.fn.poisedTabs = (options = {}) ->
  this.each ->
    $this = $(this)
    unless $this.data('poised.tabs')
      plugin = new $.poised.tabs(this, options)
      $this.data('poised.tabs', plugin)
