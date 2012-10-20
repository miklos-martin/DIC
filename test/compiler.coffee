chai = require 'chai'
chai.should()

compiler = require '../lib/compiler'
container = compiler.getContainer()

describe 'Compiler', ->
  it 'should parse a yaml and set the parameters from it', (done) ->
    yaml = "#{__dirname}/fixtures/parameters.yml"
    compiler.load yaml, ->
      container.get('key').should.equal 'Value from parameters.yml'
      container.get('key2').should.equal 'This is an other value'
      done()