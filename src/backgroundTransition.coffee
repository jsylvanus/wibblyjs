
class BackgroundTransition

  constructor : (@background, @duration) ->
    @finished = if @duration > 0 then no else yes
    if @crappySupport()
      @finished = yes
    else
      @start_time = @getSupportedStartTime()


  process : (canvas, context, dimensions, timestamp) ->
    if timestamp is 0
      @finished = yes

    # bump start time forward if background isn't ready yet
    if not @background.ready
      @start_time = timestamp
      return

    context.save()

    if timestamp > @start_time + @duration
      @finished = yes
      context.globalAlpha = 1.0
    else
      context.globalAlpha = (timestamp - @start_time) / @duration

    context.globalCompositeOperation = 'source-atop'

    @background.renderToCanvas canvas, context, timestamp

    context.restore()
    

  getSupportedStartTime : ->
    if window.performance?.now? then performance.now() else Date.now()


  crappySupport : ->
    missing_dt_now = typeof Date.now isnt 'function'
    has_raf = typeof window.requestAnimationFrame is 'function'
    is_ios = /iPad|iPhone|iPod/.test(navigator.platform)

    is_ios or missing_dt_now or not has_raf
    
module.exports = BackgroundTransition
