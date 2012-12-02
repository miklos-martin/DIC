class DIC
  constructor: () ->
    @values = {}
    @set 'container', @

  set: (key, value) ->
    @values[key] = value

  get: (key) ->
    if @has key
      try
        return @values[key] @
      catch e
        return @values[key]
    else
      return require key

  has: (key) ->
    return key of @values

module.exports = new DIC
