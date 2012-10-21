chai = require 'chai'
chai.should()

compiler = require '../lib/compiler'
container = compiler.getContainer()

describe 'Compiler', ->
  describe '.nake', ->
    it 'should remove @ from the beginning of a string', ->
      compiler.nake('@serviceId').should.equal 'serviceId'

    it 'should remove leading and trailing %', ->
      compiler.nake('%parameterKey%').should.equal 'parameterKey'

  describe '.compileParameters', ->
    it 'should parse a yaml and set the parameters from it', (done) ->
      yaml = "#{__dirname}/fixtures/config/parameters.yml"
      compiler.load yaml, ->
        container.get('param').should.equal 'Value from parameters.yml'
        container.get('param_two').should.equal 'This is an other value'
        done()

  describe '.compileServices', ->
    it 'should set services based on a yaml file', (done) ->
      yaml = "#{__dirname}/fixtures/config/services.yml"
      compiler.load yaml, ->
        foo = container.get 'foo'
        foo.should.have.property('bar').with.length(3)
        foo.bar.should.equal 'bar'
        done()

    it 'should be able to inject any other parameter or sevice to a new one from the container', (done) ->
      yaml = "#{__dirname}/fixtures/config/injector.yml"
      compiler.load yaml, ->
        bar = container.get 'bar'

        # injected plain value
        bar.should.have.property 'injected'
        bar.injected.should.equal 'injected'

        # injected parameter
        bar.should.have.property 'param'
        bar.param.should.equal 'Value from parameters.yml'

        # injected service
        bar.should.have.property 'foo'
        bar.foo.should.have.property('bar').with.length(3)
        bar.foo.bar.should.equal 'bar'

        done()

    it 'can do all this at once, and can rewrite the existing parameters and services', (done) ->
      yaml = "#{__dirname}/fixtures/config/allinone.yml"
      compiler.load yaml, ->
        container.get('param').should.equal 'it is rewritten'
        foo = container.get 'foo'
        foo.should.have.property('bar').with.length(6)
        foo.bar.should.equal 'barbar'

        # And the fun part
        bar = container.get 'bar'

        bar.should.have.property 'param'
        bar.param.should.equal 'it is rewritten'

        bar.should.have.property 'foo'
        bar.foo.should.have.property('bar').with.length(6)
        bar.foo.bar.should.equal 'barbar'

        done()

    it 'should inject dependencies through set* methods', (done) ->
      yaml = "#{__dirname}/fixtures/config/setter.yml"
      compiler.load yaml, ->
        setter = container.get('setter')
        setter.should.have.property 'data'
        setter.data.should.equal container.get 'setdata'

        done()