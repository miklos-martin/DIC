chai = require 'chai'
chai.should()
container = require '../lib/dic'

describe 'DIC', ->
  it ' should set a parameter', ->
    container.set 'key', 'value'
    container.get('key').should.equal 'value'

  it 'should be capable to register callable services', ->
    container.set 'callable', ->
      -> 'foo'

    callable = container.get 'callable'
    callable().should.equal 'foo'

  it 'should allow to inject parameters', ->
    container.set 'usesparam', (c) ->
      return c.get 'key'

    container.get('usesparam').should.equal 'value'
  
  it 'should inject services as well', ->
    container.set 'usesservice', (c) ->
      -> c.get('callable')()
    
    callable = container.get 'usesservice'
    callable().should.equal 'foo'

  it 'should handle native modules automatically', ->
    # which means you don't have to register for example 'fs' to retrieve it from the container
    container.get('fs').should.equal( require 'fs' )

  it 'should not be a problem to have circular references', ->
    container.set 'circularServiceA', (c) ->
      CircularService = require "#{__dirname}/fixtures/circularService"
      new CircularService c.get 'circularServiceB'
    container.set 'circularServiceB', (c) ->
      CircularService = require "#{__dirname}/fixtures/circularService"
      new CircularService c.get 'circularServiceA'

    circular = container.get 'circularServiceA'
    circular.should.have.property 'otherService'
    circular.otherService.should.have.property 'otherService'
    circular.otherService.otherService.should.have.property 'otherService'

  describe '.has()', ->
    it 'should tell if the container has something with the given key or not', ->
      container.has('usesservice').should.be.true
      container.has('nonexistingkey').should.be.false
