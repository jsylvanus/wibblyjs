SolidBackground = require('./solidBackground')
AnigifBackground = require('./AnigifBackground')
VideoBackground = require('./videoBackground')
ImageBackground = require('./imageBackground')

class BackgroundFactory

  setFallbackColor : (color) ->
    ImageBackground.SetFallbackColor color

  # class method, constructs appropriate strategy for a data-background string.
  create : (attribute_string = 'solid #000') ->

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

      when 'anigif'
        new AnigifBackground(segments[1])

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

module.exports = BackgroundFactory
