String.prototype.toCamel = ->
  str = @replace /((\-|_)[a-z])/g, ($1) -> $1[1].toUpperCase()
  str[0].toLowerCase() + str.slice(1)

String.prototype.toCapitalCamel = ->
  str = @toCamel()
  str[0].toUpperCase() + str.slice(1)

String.prototype.toDash = ->
  str = @replace /(_[a-z]|[A-Z])/g, ($1) -> "-" + $1.replace('_', '')
  str = str.slice(1) if str[0] is "-"
  str.toLowerCase()

String.prototype.toUnderscore = ->
  str = @replace /(\-[a-z]|[A-Z])/g, ($1) -> "_" + $1.replace('-', '')
  str = str.slice(1) if str[0] is "_"
  str.toLowerCase()

String.prototype.toLabel = ->
  str = @replace /(\-[a-z]|_[a-z]|[A-Z])/g, ($1) ->
    " " + if $1[1] then $1[1]?.toUpperCase() else $1
  str = str.slice(1) if str[0] is " "
  str[0].toUpperCase() + str.slice(1)
