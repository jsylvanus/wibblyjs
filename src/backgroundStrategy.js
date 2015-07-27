// Generated by CoffeeScript 1.9.3
(function() {
  this.BackgroundStrategy = (function() {
    BackgroundStrategy.Factory = function(attribute_string) {
      var segments;
      if (attribute_string == null) {
        attribute_string = 'solid #000';
      }
      if (typeof attribute_string !== 'string') {
        throw "attribute_string is not a string";
      }
      segments = attribute_string.split(' ');
      if (segments.length < 2) {
        throw "background attribute format is \"type [params...]\" with minimum of one parameter.";
      }
      switch (segments[0]) {
        case 'solid':
          return new SolidBackground(segments[1]);
        case 'image':
          return new ImageBackground(segments[1]);
        default:
          throw "\"" + segments[0] + "\" is not a valid background type";
      }
    };

    function BackgroundStrategy() {
      this.ready = false;
    }

    BackgroundStrategy.prototype.getDimensions = function(element) {
      return new Dimensions(element.width, element.height);
    };

    BackgroundStrategy.prototype.renderToCanvas = function(element, context, dTime) {
      if (dTime == null) {
        dTime = 0;
      }
      return null;
    };

    BackgroundStrategy.prototype.setCallback = function(fn) {
      return null;
    };

    return BackgroundStrategy;

  })();

}).call(this);
