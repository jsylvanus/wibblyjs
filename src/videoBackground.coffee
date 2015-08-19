
class @VideoBackground extends @BackgroundStrategy

  constructor: (baseurl) ->
    @debug = false
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
    basicSupport = typeof element.play is 'function' and typeof requestAnimationFrame is 'function'
    iOS = /iPad|iPhone|iPod/.test(navigator.platform)

    basicSupport and not iOS # iOS can't use video as a source


  renderToCanvas : (element, context, dTime = 0) ->
    return if not @ready

    dims = @getDimensions element
    box = @getRenderBox(dims, @video)

    if @debug
      console.log dims, box, element, context, @video
      @debug = false
    
    # console.log box, dims
    context.drawImage(@video, box.source.x, box.source.y, box.dims.width, box.dims.height, 0, 0, dims.vector.values[0], dims.vector.values[1])

    # context.drawImage(@video, offset.x(), offset.y(), scaledDims.width(), scaledDims.height())
    

  # toggles @ready and fires @callback if it's been set
  setReady : ->
    @ready = yes
    @callback() if @callback isnt null


  setCallback : (fn) ->
    @callback = fn

