class DIC
  constructor: () ->
    @values = {}
    @set 'container', @

  set: (key, value) ->
    @values[key] = value

  get: (key) ->
    try
      return @values[key] @
    catch e
      return @values[key]

module.exports = new DIC
