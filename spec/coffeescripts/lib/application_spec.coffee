window.startApp = ->
  $(window).trigger 'startedApp'
  $(window).data('has-started', true)

beforeAll (done) ->
  if $(window).data('has-started')
    done()
  else
    $(window).one 'startedApp', done
