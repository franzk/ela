$(document).ready ->
  touchOriginX = touchOriginY = 0
  $('body').on 'touchstart', (e) ->
    touchOriginX = e.originalEvent.touches[0].clientX
    touchOriginY = e.originalEvent.touches[0].clientY

  $('body').on 'touchmove', (e) ->
    directionX = e.originalEvent.touches[0].clientX - touchOriginX # <0 = left, >0 = right
    directionY = e.originalEvent.touches[0].clientY - touchOriginY # <0 = up, >0 = down

    $target = $(e.target)
    scrollables = $target.closest('.scroll, .scroll-y, .scroll-x')
    isTouchable = $target.closest('.touch').length
    isScrollable = scrollables.length and
      # Remove iOS rubber band effect - vertical
      ((not (directionY > 0 and scrollables.scrollTop() <= 0) and
      not (directionY < 0 and (scrollables.scrollTop() + scrollables.innerHeight()) >= scrollables[0].scrollHeight)) or
      # horizontal
      (not (directionX > 0 and scrollables.scrollLeft() <= 0) and
      not (directionX < 0 and (scrollables.scrollLeft() + scrollables.innerWidth()) >= scrollables[0].scrollWidth)))
    e.preventDefault() if isTouchable or !isScrollable
