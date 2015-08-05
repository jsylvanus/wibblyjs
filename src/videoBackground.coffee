
class @VideoBackground extends @BackgroundStrategy

  constructor: (baseurl) ->
    super()
    @requiresRedrawing = yes
    throw "No HTML5 video support detected" if not @detectVideoSupport()
    
    @video = @createVideoElement(baseurl)
    document.video_test = @video


  createVideoElement : (baseurl) ->
    video = document.createElement('video')
    video.addEventListener 'playing', => @setReady()
    @setAttribute video, 'poster', "#{baseurl}.jpg"
    @setAttribute video, 'autoplay', 'autoplay'
    @setAttribute video, 'loop', 'loop'
    video.appendChild @createSource("#{baseurl}.webm", 'video/webm; codecs="vp8.0, vorbis"')
    video.appendChild @createSource("#{baseurl}.ogv", 'video/ogg; codecs="theora, vorbis"')
    video.appendChild @createSource("#{baseurl}.mp4", 'video/mp4; codecs="avc1.4D401E, mp4a.40.2"')
    video


  setAttribute : (element, name, value) ->
    attr = document.createAttribute name
    attr.value = value
    element.attributes.setNamedItem attr


  createSource: (path, type) ->
    source = document.createElement 'source'
    @setAttribute source, 'type', type
    @setAttribute source, 'src', path
    source


  detectVideoSupport : ->
    element = document.createElement('video')
    # rAF could be polyfill'd if not present, we mostly just need to know that video is supported
    typeof element.play is 'function' and typeof requestAnimationFrame is 'function'


  renderToCanvas : (element, context, dTime = 0) ->
    return if not @ready

    dims = @getDimensions element
    imageDims = @getDimensions @video

    scaledDims = imageDims.scaleToFit(dims)
    offset = scaledDims.centerOffset(dims)

    context.drawImage(@video, offset.x(), offset.y(), scaledDims.width(), scaledDims.height())
    

  # toggles @ready and fires @callback if it's been set
  setReady : ->
    @ready = yes
    @callback() if @callback isnt null


  setCallback : (fn) ->
    @callback = fn

