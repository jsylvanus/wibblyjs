ImageBackground = require('./imageBackground')

class AnigifBackground extends ImageBackground

  constructor : (url) ->
    super(url)
    @requiresRedrawing = yes

  renderToCanvas : (element, context, dTime = 0) ->
    @imageContext.drawImage @image, 0, 0 if @ready
    super(element, context, dTime)

module.exports = AnigifBackground
