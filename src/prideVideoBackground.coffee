VideoBackground = require('./videoBackground')

hue = (value) -> "hsl(#{value * 360}, 100%, 50%)"

class PrideVideoBackground extends VideoBackground

  constructor: (baseurl) ->
    super(baseurl)
    @color = hue(0.0)

  renderToCanvas : (element, context, dTime = 0) ->
    # draw video frame
    super(element, context, dTime)

    # calculate new hue
    @color = hue((dTime % 6000.0) / 6000.0)

    # draw new hue to context
    context.save()
    context.globalCompositeOperation = 'hue'
    context.fillStyle = @color
    context.fillRect(0, 0, context.canvas.width, context.canvas.height)
    context.restore()

module.exports = PrideVideoBackground
