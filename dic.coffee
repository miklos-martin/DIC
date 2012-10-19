class Container
  constructor: () ->
    @values = {}

  set: (key, value) ->
    @values[key] = value

  get: (key) ->
    try
      return @values[key] @
    catch e
      return @values[key]

exports.container = new Container
