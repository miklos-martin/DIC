##
# This class can load yaml-s and "compile" a container based on those files
##
class Compiler
  ##
  # Dependencies
  ##
  constructor: () ->
    @container = require './dic'
    @yaml = require 'js-yaml'
    @fs = require 'fs'

  ##
  # Loading a yml config file
  ##
  load: (file, callback = ->) ->
    definitions = @yaml.safeLoad @fs.readFileSync(file, { encoding: 'UTF-8' })
    @compileParameters definitions.parameters if definitions.parameters?
    @compileServices definitions.services if definitions.services?

    callback?(@container)

  ##
  # Setting parameters
  ##
  compileParameters: (parameters) ->
    for key, parameter of parameters
      @container.set key, parameter

  ##
  # Creating services
  ##
  compileServices: (services) ->
    for id, service of services
      do (id, service) =>
        lambda = (container) =>
          serviceClass = @require service.module

          # Initiate if needed, and do constructor injection
          if typeof serviceClass is "function"
            args = []
            if service.arguments?
              args = @resolveDeps service.arguments

            obj = new serviceClass
            serviceClass.apply obj, args
          else
            obj = serviceClass

          # Do setter injection
          if service.calls?
            for method, call of service.calls
              do (obj, method, call) =>
                args = @resolveDeps call.arguments
                obj[method].apply obj, args

          # Do property injection
          if service.properties?
            for property, value of service.properties
              do ( obj, property, value ) =>
                obj[property] = @resolve value

          obj

        @container.set id, lambda

  ##
  # Resolves an argument
  ##
  resolve: (arg) =>
    if arg.match(/^@/) or arg.match(/^%.*%$/)
      @container.get @nake arg
    else
      arg

  ##
  # Resolves each arguments in an array
  ##
  resolveDeps: (args) =>
    deps = []
    for arg in args
      deps.push @resolve arg

    deps

  ##
  # Nakes a key to find in the container
  ##
  nake: (key) ->
    key.replace(/^(@|%)/, '').replace(/%$/, '')

  ##
  # Wrapper to handle modules
  ##
  require: (module) ->
    if module.indexOf("/") > 0
      module = "#{process.cwd()}/#{module}"

    require module

  getContainer: () ->
    @container

module.exports = new Compiler
