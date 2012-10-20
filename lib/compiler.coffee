class Compiler
  constructor: () ->
    @container = require './dic'
    @yaml = require 'js-yaml'

  load: (file, callback = ->) ->
    fs = require 'fs'
    fs.readFile file, (err, data) =>
      throw err if err

      definitions = @yaml.load data
      @compileParameters definitions.parameters if definitions.parameters?
      @compileServices definitions.services if definitions.services?

      callback()

  compileParameters: (parameters) ->
    for key, parameter of parameters
      @container.set key, parameter

  compileServices: (services) ->
    for id, service of services
      do (id, service) =>
        lambda = (c) =>
          cl = require service.module
          args = []
          if service.arguments?
            deps = @resolveDeps service.arguments
            for arg in service.arguments
              arg = @nake arg
              arg = if arg in deps then c.get arg else arg
              args.push arg
          new cl args

        @container.set id, lambda

  resolveDeps: (args) ->
    deps = []
    for arg in args
      if arg.match(/^@/) or arg.match(/^%.*%$/)
        deps.push @nake arg
    deps

  nake: (key) ->
    key.replace(/^(@|%)/, '').replace(/%$/, '')

  getContainer: () ->
    @container

module.exports = new Compiler
