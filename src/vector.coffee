
# simple vector class
# has support for > 3 values but currently only uses the first 3 as x, y, z
#
# NOTE: will probably expand this as required

class @Vector


  constructor: (@values...) -> @values


  # TODO: Maybe make a better version? this won't catch nested objects, should 
  # that ever be required by the class. Not needed for now.
  clone : -> new Vector(@values...)
    
  reverse : -> @scale(-1)

  # multiplies all values in vector and returns the new result
  scale : (scalar) ->
    vec = @clone()
    vec.mutScale(scalar)
    vec
  

  # mutator version of scale()
  mutScale : (scalar) ->
    @values = @values.map (x) -> x * scalar

  equals : (other) ->
    return false if other.values.length != @values.length
    for val, idx in @values
      return false if other.values[idx] != val
    true

  # named accessors...
  
  x : ->
    return @values[0] if @values.length > 0
    null

  y : ->
    return @values[1] if @values.length > 1
    null

  z : ->
    return @values[2] if @values.length > 2
    null
