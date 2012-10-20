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