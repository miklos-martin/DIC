This is a cool DIC for node projects, written in coffeescript.

The container itself couldn't be more simple, it's based on [twittee](https://github.com/fabpot/twittee "Twittee").
And there is a compiler for this container, and it

You can use the container directly, like this:
```coffeescript
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
```
It's not so fun to do this way, but parameters and services can also be described in yaml files.

Here is an example:
```yml
# parameters.yml
parameters:
  param: Value from parameters.yml
  param_two: This is an other value
```

If you tell the `compiler` to load this `yml`, it will set those params to the container.

```coffeescript
describe '.compileParameters', ->
    it 'should parse a yaml and set the parameters from it', (done) ->
      yaml = "path/to/parameters.yml"
      compiler.load yaml, ->
        container.get('param').should.equal 'Value from parameters.yml'
        container.get('param_two').should.equal 'This is an other value'
        done()
```

You can specify services as well. A service can be any module.
The compiler will check if you gave a path, or a modulename. If a path is given it has to be relative to your project's root directory.

```yml
# services.yml

services:
  foo:
    module: 'test/fixtures/foo'
```

You can pass arguments to a service's constructor (if it is a class, of course). The compiler will decide, if the given module needs to be initiated or not.
It will recognize, if an argument is a parameter if you put it's name between % signs. You can indicate a service with an @ at the beginning - like in [symfony](https://github.com/symfony/symfony "Symfony 2"):
```yml
# services.yml

services:
  bar:
    module: 'test/fixtures/bar'
    arguments: ['injected', '%param%', '@foo']
```

You can also use setter injection:
```yml
# services.yml

parameters:
  setdata: "this has been injected by a set* method"

services:
  setter:
    module: "test/fixtures/setter"
    calls:
      setData:
        arguments:
          - '%setdata%'
```

Note, that you can load `yamls` as many times as you want, and it will add and add again to the same container, overriding existing keys.
Also note, that the container is super-lazy. A service gets initiated the first time it's called.
