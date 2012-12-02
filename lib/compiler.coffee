class Compiler
  constructor: () ->
    @container = require './dic'
    @yaml = require 'js-yaml'

  load: (file, callback = ->) ->
    definitions = require file
    @compileParameters definitions.parameters if definitions.parameters?
    @compileServices definitions.services if definitions.services?

    callback?(@container)

  compileParameters: (parameters) ->
    for key, parameter of parameters
      @container.set key, parameter

  compileServices: (services) ->
    for id, service of services
      do (id, service) =>
        lambda = (c) =>
          cl = @require service.module
          if typeof cl is "function"
            args = []
            if service.arguments?
              args = @resolveDeps c, service.arguments

            obj = new cl
            cl.apply obj, args
          else
            obj = cl

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

  require: (module) ->
    if module.indexOf("/") > 0
      module = "#{process.cwd()}/#{module}"

    require module

  getContainer: () ->
    @container

module.exports = new Compiler
