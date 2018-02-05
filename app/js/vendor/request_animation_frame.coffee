lastTime = 0
vendors = ['webkit', 'moz']

for vendor in vendors when !window.requestAnimationFrame
  window.requestAnimationFrame = window["#{vendor}RequestAnimationFrame"]
  window.cancelAnimationFrame = window["#{vendor}CancelAnimationFrame"] || window["#{vendor}CancelRequestAnimationFrame"];

unless window.requestAnimationFrame
  window.requestAnimationFrame = (callback, element) ->
    currTime = Date.now()
    timeToCall = Math.max(0, 16 - (currTime - lastTime))
    id = setTimeout ->
      callback(currTime + timeToCall)
    , timeToCall
    lastTime = currTime + timeToCall
    id

unless window.cancelAnimationFrame
  window.cancelAnimationFrame = window.clearTimeout
