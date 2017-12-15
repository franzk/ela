window.startApp = ->
  if not ELA.router? and ELA.loadedData and $('html').hasClass('wf-active')
    ELA.router = new ELA.Router()
    Backbone.history.start()

# Preload font
# This avoids canvas resize issues on iOS 10.3
WebFont.load
  custom:
    families: ['Roboto:n3,n4,n5']
  active: startApp

if /iP(od|ad|hone)/.test(navigator.userAgent)
  $('html').addClass('ios')

Hammer.defaults.preset = [
  [Hammer.Rotate, { enable: false }],
  [Hammer.Pinch, { enable: false }, ['rotate']],
  [Hammer.Swipe, { enable: false }],
  [Hammer.Pan, { enable: false }, ['swipe']],
  [Hammer.Tap],
  [Hammer.Tap, { event: 'doubletap', taps: 2 }, ['tap']],
  [Hammer.Press]
]

window.ELA = {}

window.debug = (args...) ->
  if ELA.debug
    first = args[0]
    if _.isFunction(first)
      first()
    else
      console.log.apply console, args

window.HAML ||= {}
window.HAML.cleanValue ||= (text) ->
  if text is null or text is undefined then '' else text
window.HAML.escape ||= (text) ->
  "#{text}"
  .replace(/&/g, '&amp;')
  .replace(/</g, '&lt;')
  .replace(/>/g, '&gt;')
  .replace(/\"/g, '&quot;')

window.delay = (timeout, callback = null) ->
  if _.isFunction(timeout)
    setTimeout timeout, 0
  else
    setTimeout callback, timeout

String::toFunction = ->
  arr = this.split('.')
  fn = window or this
  fn = fn[elem] for elem in arr
  throw new Error("#{this} seems not to describe a function") unless _.isFunction(fn)
  fn

window.t = (translations...) ->
  options = if _.isObject(_.last(translations)) then translations.pop() else {}
  for translation in translations
    str = ELA.labels[translation]
    if str
      return str.replace(/{{([a-zA-Z0-9_]+)}}/g, (match, v) -> options[v])

  return options.defaultValue if options.defaultValue?
  return null if not str? and options.returnNull
  "#{translations} not found"

window.flattenObject = (obj, result = {}, path = []) ->
  for key, newObj of obj
    newPath = path.slice() # clone array
    newPath.push(key)
    if typeof newObj is 'object'
      flattenObject(newObj, result, newPath)
    else
      result[newPath.join('.')] = newObj
  result

_.containsAny = (arr, values...) ->
  values = values[0] if _.isArray(values[0])
  _.some values, (value) ->
    _.contains(arr, value)
