class Bar
  constructor: (config) ->
    # It's not that pretty for now
    @injected = config[0]
    @param = config[1]
    @foo = config[2]

module.exports = Bar