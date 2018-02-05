window.keys =
  ALT: false
  SHIFT: false
  x: false
  y: false
  z: false

$(window).on 'keydown', (e) ->
  switch e.keyCode
    when 16 then window.keys.SHIFT = true
    when 18 then window.keys.ALT = true
    when 88 then window.keys.x = true
    when 89 then window.keys.y = true
    when 90 then window.keys.z = true

$(window).on 'keyup', (e) ->
  switch e.keyCode
    when 16 then window.keys.SHIFT = false
    when 18 then window.keys.ALT = false
    when 88 then window.keys.x = false
    when 89 then window.keys.y = false
    when 90 then window.keys.z = false
