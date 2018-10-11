doneHandler = undefined

window.startApp = ->
  if doneHandler
    doneHandler()
  else
    setTimeout(startApp, 100)

beforeAll (done) ->
  doneHandler = done
