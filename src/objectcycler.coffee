
class @objectCycler
  
  constructor : ( data = [] ) ->
    if typeof data is 'string'
      if typeof jQuery isnt 'undefined' # this implies a jquery selector
        data = jQuery(data).toArray()
      else
        throw 'jQuery must be available to construct with a selector.'
    @data = data
    @index = 0

  setPosition : (position) =>
    idx = position - 1 # make 0-based
    throw new Error('index out of bounds') if idx < 0 or idx > @data.length - 1
    @index = idx

  current : => @data[@index]

  position : =>
    return 0 if @data.length is 0
    @index + 1

  count : => @data.length

  next : =>
    return null if @data.length is 0
    nextIndex = @index
    nextIndex += 1
    nextIndex = 0 if nextIndex == @data.length
    @index = nextIndex
    @current()

  prev : =>
    return null if @data.length is 0
    nextIndex = @index
    nextIndex -= 1
    nextIndex = @data.length - 1 if nextIndex < 0
    @index = nextIndex
    @current()

  at : (idx) =>
    idx -= 1 # at(1) = @data[0]
    return null if idx < 0 or idx > @data.length - 1
    @data[@index = idx]

  first : =>
    return null if @data.length is 0
    @data[@index = 0]

  last : =>
    return null if @data.length is 0
    @data[@index = @data.length - 1]

  # nondestructive peek functions
  
  _peekFn : (fname, params...) ->
    idx = @index
    el = @[fname](params)
    @index = idx
    el

  peekAt : (idx) -> @_peekFn 'at', idx
  peekNext : -> @_peekFn 'next'
  peekPrev : -> @_peekFn 'prev'
  peekFirst : -> @_peekFn 'first'
  peekLast : -> @_peekFn 'last'

