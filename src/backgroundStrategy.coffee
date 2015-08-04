
class @BackgroundStrategy

  # class method, constructs appropriate strategy for a data-background string.
  @Factory : (attribute_string = 'solid #000') ->

    # data safety
    if typeof attribute_string isnt 'string'
      throw "attribute_string is not a string"

    segments = attribute_string.split(' ')
    if segments.length < 2
      throw "background attribute format is \"type [params...]\" with minimum of one parameter."

    # interpret input and construct class
    switch segments[0]

      when 'solid'
        new SolidBackground(segments[1])

      when 'video'
        try
          new VideoBackground(segments[1])
        catch error
          if error == "No HTML5 video support detected"
            new ImageBackground(segments[1] + '.jpg')
          else
            throw error

      when 'image'
        if segments.length is 2
          new ImageBackground(segments[1])
        else
          new ImageBackground(segments.slice(1))

      else
        throw "\"#{segments[0]}\" is not a valid background type"

  
  constructor : ->
    @ready = no
    @requiresRedrawing = no

  
  # constructs a Dimensions object representing the element's width/height
  # given element MUST have width/height attributes set (e.g. canvas)
  getDimensions : (element) ->
    return new Dimensions(element.videoWidth, element.videoHeight) if element instanceof HTMLVideoElement
    new Dimensions(element.width, element.height)

  # the following are intended to be overridden by subclasses

  # Note dTime (Delta Time) is intended to be time-since-last-render, currently unused.
  # dTime exists to allow for smooth animation based on requestAnimationFrame()
  renderToCanvas : (element, context, dTime = 0) ->
    null # implement me

  setCallback: (fn) ->
    null # implement me
