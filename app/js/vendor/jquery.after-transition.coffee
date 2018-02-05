$ = jQuery
$.fn.extend
  afterAnimation: (fn) ->
    $(this).bind 'oanimationend animationend webkitAnimationEnd otransitionend transitionend webkitTransitionEnd', fn

  afterTransitionForAddingClass: (className, fn) ->
    unless $(this).hasClass('active')
      $(this)
        .toggleClass('active', true)
        .afterAnimation(fn)
    else
      fn()

  afterTransitionForRemovingClass: (className, fn) ->
    if $(this).hasClass('active')
      $(this)
        .toggleClass('active', false)
        .afterAnimation(fn)
    else
      fn()
