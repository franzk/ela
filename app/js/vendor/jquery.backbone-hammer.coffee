$.fn.hammer = (options) ->
  @each ->
    $el = $(this)
    unless $el.data('hammer')
      $el.data('hammer', new Hammer($el[0], options))

Backbone.View::_setElement =
  do (originalFunction = Backbone.View::_setElement) ->
    ->
      originalFunction.apply(this, arguments)
      if @hammerjs is true
         @$el.hammer()
      else
        @$el.hammer(_.clone(@hammerjs)) if @hammerjs
      @hammer = @$el.data('hammer')

Hammer.Manager::emit =
  do (originalFunction = Hammer.Manager::emit) ->
    (type, data) ->
      originalFunction.apply(this, arguments)
      $target = $(data.target)
      if @element isnt data.target
        return if $target.data('hammer')?
        for el in $target.parentsUntil($(@element))
          return if $(el).data('hammer')?
      $target.trigger
        type: type
        gesture: data
