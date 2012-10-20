class Compiler
  constructor: () ->
    @container = require './dic'

    @yaml = require 'js-yaml'

  load: (file, callback = ->) ->
    fs = require 'fs'
    fs.readFile file, (err, data) =>
      definitions = @yaml.load data
      @compileParameters definitions.parameters
      #@compileServices definitions.services

      callback()

  compileParameters: (parameters) ->
    for key, parameter of parameters
      @container.set key, parameter

  getContainer: () ->
    @container

module.exports = new Compiler
