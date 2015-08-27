
class @FrameQueue

  internal_counter = 0

  constructor : (pool_max = 100) ->
    @pool = new Array(pool_max)
    @pool[i] = { origin: null, callback_identity: null, callback: null } for _, i in @pool

  count : -> internal_counter
