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
            args = @resolveDeps c, service.arguments

          obj = new cl
          cl.apply obj, args

          if service.calls?
            for method, call of service.calls
              do (cl, method, call) =>
                args = @resolveDeps c, call.arguments
                obj[method].apply obj, args
          obj

        @container.set id, lambda

  resolveDeps: (container, args) ->
    deps = []
    for arg in args
      if arg.match(/^@/) or arg.match(/^%.*%$/)
        deps.push container.get @nake arg
      else
        deps.push arg

    deps

  nake: (key) ->
    key.replace(/^(@|%)/, '').replace(/%$/, '')

  getContainer: () ->
    @container

module.exports = new Compiler
