(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var AnigifBackground, ImageBackground,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

ImageBackground = require('./imageBackground');

AnigifBackground = (function(superClass) {
  extend(AnigifBackground, superClass);

  function AnigifBackground(url) {
    AnigifBackground.__super__.constructor.call(this, url);
    this.requiresRedrawing = true;
  }

  AnigifBackground.prototype.renderToCanvas = function(element, context, dTime) {
    if (dTime == null) {
      dTime = 0;
    }
    if (this.ready) {
      this.imageContext.drawImage(this.image, 0, 0);
    }
    return AnigifBackground.__super__.renderToCanvas.call(this, element, context, dTime);
  };

  return AnigifBackground;

})(ImageBackground);

module.exports = AnigifBackground;


},{"./imageBackground":11}],2:[function(require,module,exports){
var AnimationFrameDispatch,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

AnimationFrameDispatch = (function() {
  function AnimationFrameDispatch() {
    this.frame = bind(this.frame, this);
    this.onResizeEvent = bind(this.onResizeEvent, this);
    this.wibblyElementList = [];
    this.resize_flagged = true;
    this.running = false;
    this.raf_confirmed = false;
    window.addEventListener('resize', this.onResizeEvent);
  }

  AnimationFrameDispatch.prototype.onResizeEvent = function() {
    this.resize_flagged = true;
    if (!this.raf_confirmed) {
      this.resizeAll();
      return this.redraw(0, true);
    }
  };

  AnimationFrameDispatch.prototype.register = function(element) {
    this.wibblyElementList.push(element);
    if (!this.running) {
      this.running = true;
      return requestAnimationFrame(this.frame);
    }
  };

  AnimationFrameDispatch.prototype.frame = function(timestamp) {
    if (timestamp == null) {
      timestamp = 0;
    }
    this.raf_confirmed = true;
    this.running = true;
    requestAnimationFrame(this.frame);
    if (this.needsResize()) {
      this.resizeAll();
      return this.redraw(timestamp, true);
    } else {
      return this.redraw(timestamp);
    }
  };

  AnimationFrameDispatch.prototype.redraw = function(timestamp, force) {
    var i, item, len, ref, results;
    if (force == null) {
      force = false;
    }
    ref = this.wibblyElementList;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      item = ref[i];
      if (force || item.needsAnimation()) {
        results.push(item.draw(timestamp));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  AnimationFrameDispatch.prototype.needsResize = function() {
    if (!this.resize_flagged) {
      return false;
    }
    this.resize_flagged = false;
    return true;
  };

  AnimationFrameDispatch.prototype.resizeAll = function() {
    var i, item, len, ref, results;
    ref = this.wibblyElementList;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      item = ref[i];
      results.push(item.resize());
    }
    return results;
  };

  return AnimationFrameDispatch;

})();

module.exports = AnimationFrameDispatch;


},{}],3:[function(require,module,exports){
var AnigifBackground, BackgroundFactory, ImageBackground, SolidBackground, VideoBackground;

SolidBackground = require('./solidBackground');

AnigifBackground = require('./AnigifBackground');

VideoBackground = require('./videoBackground');

ImageBackground = require('./imageBackground');

BackgroundFactory = (function() {
  function BackgroundFactory() {}

  BackgroundFactory.prototype.setFallbackColor = function(color) {
    return ImageBackground.SetFallbackColor(color);
  };

  BackgroundFactory.prototype.create = function(attribute_string) {
    var error, error1, segments;
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
      case 'anigif':
        return new AnigifBackground(segments[1]);
      case 'video':
        try {
          return new VideoBackground(segments[1]);
        } catch (error1) {
          error = error1;
          if (error === "No HTML5 video support detected") {
            return new ImageBackground(segments[1] + '.jpg');
          } else {
            throw error;
          }
        }
        break;
      case 'image':
        if (segments.length === 2) {
          return new ImageBackground(segments[1]);
        } else {
          return new ImageBackground(segments.slice(1));
        }
        break;
      default:
        throw "\"" + segments[0] + "\" is not a valid background type";
    }
  };

  return BackgroundFactory;

})();

module.exports = BackgroundFactory;


},{"./AnigifBackground":1,"./imageBackground":11,"./solidBackground":14,"./videoBackground":16}],4:[function(require,module,exports){
var BezierMask, ScalableBezier;

ScalableBezier = require('./scalableBezier');

BezierMask = (function() {
  var abs;

  abs = Math.abs;

  BezierMask.fromElementAttributes = function(element) {
    var bottom, top;
    top = ScalableBezier.FromAttribute(element, 'data-top');
    bottom = ScalableBezier.FromAttribute(element, 'data-bottom');
    return new BezierMask(top, bottom);
  };

  BezierMask.prototype.updateCanvasDimensions = function(dims) {
    this.clipCanvas.width = dims.width;
    return this.clipCanvas.height = this.totalHeight(dims);
  };

  function BezierMask(top1, bottom1) {
    this.top = top1 != null ? top1 : null;
    this.bottom = bottom1 != null ? bottom1 : null;
    this.createClipCanvas();
    this.lastDims = null;
  }

  BezierMask.prototype.createClipCanvas = function() {
    this.clipCanvas = document.createElement('canvas');
    this.clipCanvas.width = 1;
    this.clipCanvas.height = 1;
    return this.clipContext = this.clipCanvas.getContext('2d');
  };

  BezierMask.prototype.updateClippingCanvas = function(dims) {
    this.updateCanvasDimensions(dims);
    this.clipContext.beginPath();
    this.drawTop(dims);
    this.drawBottom(dims);
    this.clipContext.closePath();
    return this.clipContext.fill();
  };

  BezierMask.prototype.drawTop = function(dims) {
    var topBezier;
    if (this.top !== null) {
      topBezier = this.top.scale(dims.width, abs(dims.topMargin));
      this.clipContext.moveTo(topBezier.startX, topBezier.startY);
      return topBezier.applyToCanvas(this.clipContext);
    } else {
      this.clipContext.moveTo(0, 0);
      return this.clipContext.lineTo(dims.width, 0);
    }
  };

  BezierMask.prototype.drawBottom = function(dims) {
    var bottomBezier;
    if (this.bottom !== null) {
      bottomBezier = this.bottom.scale(dims.width, abs(dims.bottomMargin)).reverse();
      return bottomBezier.applyToCanvas(this.clipContext, 0, dims.height + abs(dims.topMargin));
    } else {
      this.clipContext.lineTo(dims.width, this.totalHeight(dims));
      return this.clipContext.lineTo(0, this.totalHeight(dims));
    }
  };

  BezierMask.prototype.drawClippingShape = function(context, dims) {
    var fullDims;
    fullDims = {
      w: dims.width,
      h: this.totalHeight(dims)
    };
    if (this.lastDims === null || !this.dimensionsMatch(this.lastDims, fullDims)) {
      this.updateClippingCanvas(dims);
    }
    this.lastDims = fullDims;
    context.save();
    context.globalCompositeOperation = 'destination-in';
    context.drawImage(this.clipContext.canvas, 0, 0, fullDims.w, fullDims.h);
    return context.restore();
  };

  BezierMask.prototype.dimensionsMatch = function(last, latest) {
    return last.w === latest.w && last.h === latest.h;
  };

  BezierMask.prototype.totalHeight = function(dims) {
    return dims.height + abs(dims.topMargin) + abs(dims.bottomMargin);
  };

  return BezierMask;

})();

module.exports = BezierMask;


},{"./scalableBezier":13}],5:[function(require,module,exports){
var ElementDimensions;

ElementDimensions = (function() {
  var abs, ceil;

  abs = Math.abs;

  ceil = Math.ceil;

  function ElementDimensions() {
    this.width = 0;
    this.height = 0;
    this.topMargin = 0;
    this.bottomMargin = 0;
    this.totalHeight = 0;
  }

  ElementDimensions.prototype.updateFromElement = function(element) {
    var style;
    style = element.currentStyle || window.getComputedStyle(element);
    this.width = ceil(element.offsetWidth);
    this.height = ceil(element.offsetHeight);
    this.topMargin = ceil(parseFloat(style.marginTop));
    this.bottomMargin = ceil(parseFloat(style.marginBottom));
    if (isNaN(this.topMargin)) {
      this.topMargin = 0;
    }
    if (isNaN(this.bottomMargin)) {
      this.bottomMargin = 0;
    }
    this.totalHeight = this.height + abs(this.topMargin) + abs(this.bottomMargin);
    return this;
  };

  return ElementDimensions;

})();

module.exports = ElementDimensions;


},{}],6:[function(require,module,exports){
var Dimensions, Layer, Vector;

Vector = require('./vector');

Dimensions = require('./dimensions');

Layer = (function() {
  var elementOffset, viewport;

  viewport = null;

  Layer.Viewport = function() {
    var height, left, top, width;
    if (viewport === null) {
      viewport = new Layer();
    }
    left = window.pageXOffset;
    top = window.pageYOffset;
    width = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
    height = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
    return viewport.update(left, top, width, height);
  };

  elementOffset = function(element) {
    var left, top;
    left = element.offsetLeft;
    top = element.offsetTop;
    while (element = element.offsetParent) {
      left += element.offsetLeft;
      top += element.offsetTop;
    }
    return {
      left: left,
      top: top
    };
  };

  function Layer(left, top, width, height) {
    this.origin = new Vector(left, top);
    this.box = new Dimensions(width, height);
  }

  Layer.prototype.left = function() {
    return this.origin.x();
  };

  Layer.prototype.top = function() {
    return this.origin.y();
  };

  Layer.prototype.width = function() {
    return this.box.width();
  };

  Layer.prototype.height = function() {
    return this.box.height();
  };

  Layer.prototype.right = function() {
    return this.left() + this.width();
  };

  Layer.prototype.bottom = function() {
    return this.top() + this.height();
  };

  Layer.prototype.is_equal_to = function(other) {
    return this.origin.equals(other.origin) && this.box.equals(other.box);
  };

  Layer.prototype.is_equivalent_to = function(other) {
    return this.box.equals(other.box);
  };

  Layer.prototype.intersects = function(other) {
    return this.left() < other.right() && this.top() < other.bottom() && this.right() > other.left() && this.bottom() > other.top();
  };

  Layer.prototype.contains = function(other) {
    return this.left() <= other.left() && this.top() <= other.top() && this.bottom() >= other.bottom() && this.right() >= other.right();
  };

  Layer.prototype.update = function(left, top, width, height) {
    this.origin.update(left, top);
    this.box.update(width, height);
    return this;
  };

  Layer.prototype.updateFromElement = function(element) {
    var offset, rect;
    if (typeof element.getBoundingClientRect === 'function') {
      rect = element.getBoundingClientRect();
      offset = {
        x: window.pageXOffset,
        y: window.pageYOffset
      };
      this.update(rect.left + offset.x, rect.top + offset.y, rect.width, rect.height);
    } else {
      offset = elementOffset(element);
      this.update(offset.left, offset.top, element.offsetWidth, element.offsetHeight);
    }
    return this;
  };

  return Layer;

})();

module.exports = Layer;


},{"./dimensions":10,"./vector":15}],7:[function(require,module,exports){
var TemporaryCanvas;

TemporaryCanvas = (function() {
  function TemporaryCanvas() {
    this.internalCanvas = document.createElement('canvas');
    this.internalContext = this.internalCanvas.getContext('2d');
  }

  TemporaryCanvas.prototype.copyCanvas = function(otherCanvas) {
    this.internalCanvas.width = otherCanvas.width;
    this.internalCanvas.height = otherCanvas.height;
    return this.internalContext.drawImage(otherCanvas, 0, 0);
  };

  TemporaryCanvas.prototype.restoreToContext = function(otherContext) {
    var otherCanvas;
    otherCanvas = otherContext.canvas;
    return otherContext.drawImage(this.internalCanvas, 0, 0, otherCanvas.width, otherCanvas.height);
  };

  return TemporaryCanvas;

})();

module.exports = TemporaryCanvas;


},{}],8:[function(require,module,exports){
var BackgroundStrategy, Dimensions;

Dimensions = require('./dimensions');

BackgroundStrategy = (function() {
  function BackgroundStrategy() {
    this.lastBox = null;
    this.ready = false;
    this.requiresRedrawing = false;
    this.callback = null;
  }

  BackgroundStrategy.prototype.getDimensions = function(element) {
    if (element instanceof HTMLVideoElement) {
      return new Dimensions(element.videoWidth, element.videoHeight);
    }
    if (element instanceof HTMLImageElement) {
      return new Dimensions(element.naturalWidth, element.naturalHeight);
    }
    return new Dimensions(element.width, element.height);
  };

  BackgroundStrategy.prototype.sourceBox = function(dCanvas, dSource) {
    var offset, scaledCanvasBox;
    scaledCanvasBox = dCanvas.scaleToFit(dSource);
    offset = scaledCanvasBox.centerOffset(dSource);
    return {
      source: {
        x: Math.floor(offset.x()),
        y: Math.floor(offset.y())
      },
      dims: {
        width: Math.floor(scaledCanvasBox.width()),
        height: Math.floor(scaledCanvasBox.height())
      }
    };
  };

  BackgroundStrategy.prototype.getRenderBox = function(dCanvas, sourceElement) {
    var box, imageDims;
    if (this.lastBox !== null && dCanvas.equals(this.lastDims)) {
      box = this.lastBox;
    } else {
      this.lastDims = dCanvas;
      imageDims = this.getDimensions(sourceElement);
      this.lastBox = this.sourceBox(dCanvas, imageDims);
      if (this.lastBox.source.x < 0) {
        this.lastBox.source.x = 0;
      }
      if (this.lastBox.source.y < 0) {
        this.lastBox.source.y = 0;
      }
      if (this.lastBox.dims.height > imageDims.height()) {
        this.lastBox.dims.height = imageDims.height();
      }
      if (this.lastBox.dims.width > imageDims.width()) {
        this.lastBox.dims.width = imageDims.width();
      }
      box = this.lastBox;
    }
    return box;
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

module.exports = BackgroundStrategy;


},{"./dimensions":10}],9:[function(require,module,exports){
var BackgroundTransition;

BackgroundTransition = (function() {
  function BackgroundTransition(background, duration) {
    this.background = background;
    this.duration = duration;
    this.finished = this.duration > 0 ? false : true;
    if (this.crappySupport()) {
      this.finished = true;
    } else {
      this.start_time = this.getSupportedStartTime();
    }
  }

  BackgroundTransition.prototype.process = function(canvas, context, dimensions, timestamp) {
    if (timestamp === 0) {
      this.finished = true;
    }
    if (!this.background.ready) {
      this.start_time = timestamp;
      return;
    }
    context.save();
    if (timestamp > this.start_time + this.duration) {
      this.finished = true;
      context.globalAlpha = 1.0;
    } else {
      context.globalAlpha = (timestamp - this.start_time) / this.duration;
    }
    context.globalCompositeOperation = 'source-atop';
    this.background.renderToCanvas(canvas, context, timestamp);
    return context.restore();
  };

  BackgroundTransition.prototype.getSupportedStartTime = function() {
    var ref;
    if (((ref = window.performance) != null ? ref.now : void 0) != null) {
      return performance.now();
    } else {
      return Date.now();
    }
  };

  BackgroundTransition.prototype.crappySupport = function() {
    var has_raf, is_ios, missing_dt_now;
    missing_dt_now = typeof Date.now !== 'function';
    has_raf = typeof window.requestAnimationFrame === 'function';
    is_ios = /iPad|iPhone|iPod/.test(navigator.platform);
    return is_ios || missing_dt_now || !has_raf;
  };

  return BackgroundTransition;

})();

module.exports = BackgroundTransition;


},{}],10:[function(require,module,exports){
var Dimensions, Vector;

Vector = require('./vector');

Dimensions = (function() {
  Dimensions.FromVector = function(vec) {
    return new Dimensions(vec.x(), vec.y());
  };

  function Dimensions(width, height) {
    this.vector = new Vector(width, height);
  }

  Dimensions.prototype.equals = function(other_distance) {
    return this.vector.equals(other_distance.vector);
  };

  Dimensions.prototype.scale = function(factor) {
    var box;
    box = new Dimensions(this.vector.x(), this.vector.y());
    box.mutableScale(factor);
    return box;
  };

  Dimensions.prototype.update = function(width, height) {
    return this.vector.update(width, height);
  };

  Dimensions.prototype.mutableScale = function(factor) {
    return this.vector.mutScale(factor);
  };

  Dimensions.prototype.width = function() {
    return this.vector.x();
  };

  Dimensions.prototype.height = function() {
    return this.vector.y();
  };

  Dimensions.prototype.scaleToFill = function(other) {
    var ratio, ratio_x, ratio_y;
    ratio_x = other.width() / this.width();
    ratio_y = other.height() / this.height();
    ratio = ratio_x > ratio_y ? ratio_x : ratio_y;
    return Dimensions.FromVector(this.vector.scale(ratio));
  };

  Dimensions.prototype.scaleToFit = function(other) {
    var ratio, ratio_x, ratio_y;
    ratio_x = other.width() / this.width();
    ratio_y = other.height() / this.height();
    ratio = ratio_x < ratio_y ? ratio_x : ratio_y;
    return Dimensions.FromVector(this.vector.scale(ratio));
  };

  Dimensions.prototype.centerOffset = function(other) {
    var off_x, off_y;
    off_x = (other.width() - this.width()) / 2.0;
    off_y = (other.height() - this.height()) / 2.0;
    return new Vector(off_x, off_y);
  };

  return Dimensions;

})();

module.exports = Dimensions;


},{"./vector":15}],11:[function(require,module,exports){
var BackgroundStrategy, ImageBackground, SolidBackground,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BackgroundStrategy = require('./backgroundStrategy');

SolidBackground = require('./solidBackground');

ImageBackground = (function(superClass) {
  var fallbackColor;

  extend(ImageBackground, superClass);

  fallbackColor = '#000';

  ImageBackground.SetFallbackColor = function(colorstring) {
    return fallbackColor = colorstring;
  };

  function ImageBackground(url) {
    ImageBackground.__super__.constructor.call(this);
    this.callback = null;
    if (typeof url === 'string') {
      this.image = this.createImage(url);
    } else if (typeof url === 'object' && url instanceof Array) {
      this.image = this.createSrcSetImage(url);
    } else {
      throw "url provided to ImageBackground constructor must be string or array";
    }
    this.fallback = new SolidBackground(fallbackColor);
  }

  ImageBackground.prototype.renderToCanvas = function(element, context, dTime) {
    var box, dims, ref;
    if (dTime == null) {
      dTime = 0;
    }
    if (!this.ready) {
      return (ref = this.fallback) != null ? ref.renderToCanvas(element, context, dTime) : void 0;
    }
    dims = this.getDimensions(element);
    box = this.getRenderBox(dims, this.imageCanvas);
    return context.drawImage(this.imageContext.canvas, box.source.x, box.source.y, box.dims.width, box.dims.height, 0, 0, dims.vector.values[0], dims.vector.values[1]);
  };

  ImageBackground.prototype.createSrcSetImage = function(values) {
    var img;
    img = document.createElement('img');
    img.addEventListener('load', (function(_this) {
      return function() {
        return _this.setReady();
      };
    })(this));
    if (this.isSrcsetSupported()) {
      img.srcset = values.join(' ');
    } else {
      img.src = values[0];
    }
    return img;
  };

  ImageBackground.prototype.createImage = function(url) {
    var img;
    img = document.createElement('img');
    img.addEventListener('load', (function(_this) {
      return function() {
        return _this.setReady();
      };
    })(this));
    img.src = url;
    return img;
  };

  ImageBackground.prototype.createCanvasSource = function() {
    var dims;
    dims = this.getDimensions(this.image);
    this.imageCanvas = document.createElement('canvas');
    this.imageCanvas.width = dims.width();
    this.imageCanvas.height = dims.height();
    this.imageContext = this.imageCanvas.getContext('2d');
    return this.imageContext.drawImage(this.image, 0, 0);
  };

  ImageBackground.prototype.setReady = function() {
    this.createCanvasSource();
    this.ready = true;
    if (this.callback !== null) {
      return this.callback();
    }
  };

  ImageBackground.prototype.setCallback = function(fn) {
    return this.callback = fn;
  };

  ImageBackground.prototype.isSrcsetSupported = function() {
    var img;
    img = document.createElement('img');
    return typeof img.srcset === 'string';
  };

  return ImageBackground;

})(BackgroundStrategy);

module.exports = ImageBackground;


},{"./backgroundStrategy":8,"./solidBackground":14}],12:[function(require,module,exports){
var patchAnimationFrame;

patchAnimationFrame = function() {
  return (function() {
    var i, lastFrame, len, method, now, queue, ref, ref1, requestAnimationFrame, timer, vendor;
    method = 'native';
    now = Date.now || function() {
      return new Date().getTime();
    };
    requestAnimationFrame = window.requestAnimationFrame;
    ref = ['webkit', 'moz', 'o', 'ms'];
    for (i = 0, len = ref.length; i < len; i++) {
      vendor = ref[i];
      if (requestAnimationFrame == null) {
        requestAnimationFrame = window[vendor + "RequestAnimationFrame"];
      }
    }
    if (requestAnimationFrame == null) {
      method = 'timer';
      lastFrame = 0;
      queue = timer = null;
      requestAnimationFrame = function(callback) {
        var fire, nextFrame, time;
        if (queue != null) {
          queue.push(callback);
          return;
        }
        time = now();
        nextFrame = Math.max(0, 33.89 - (time - lastFrame));
        queue = [callback];
        lastFrame = time + nextFrame;
        fire = function() {
          var cb, j, len1, q;
          q = queue;
          queue = null;
          for (j = 0, len1 = q.length; j < len1; j++) {
            cb = q[j];
            cb(lastFrame);
          }
        };
        timer = setTimeout(fire, nextFrame);
      };
    }
    requestAnimationFrame(function(time) {
      var offset, ref1;
      if (time < 1e12) {
        if (((ref1 = window.performance) != null ? ref1.now : void 0) != null) {
          requestAnimationFrame.now = function() {
            return window.performance.now();
          };
          requestAnimationFrame.method = 'native-highres';
        } else {
          offset = now() - time;
          requestAnimationFrame.now = function() {
            return now() - offset;
          };
          requestAnimationFrame.method = 'native-highres-noperf';
        }
      } else {
        requestAnimationFrame.now = now;
      }
    });
    requestAnimationFrame.now = ((ref1 = window.performance) != null ? ref1.now : void 0) != null ? (function() {
      return window.performance.now();
    }) : now;
    requestAnimationFrame.method = method;
    return window.requestAnimationFrame = requestAnimationFrame;
  })();
};

module.exports = patchAnimationFrame;


},{}],13:[function(require,module,exports){
var ScalableBezier;

ScalableBezier = (function() {
  ScalableBezier.FromAttribute = function(element, attribute) {
    var attr, test;
    test = element.attributes.getNamedItem(attribute);
    if (test === null) {
      return null;
    }
    attr = test.value.split(' ').map(parseFloat);
    if (attr.length < 8) {
      throw "bezier requires 8 points";
    }
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(ScalableBezier, attr, function(){});
  };

  function ScalableBezier(startX, startY, controlX1, controlY1, controlX2, controlY2, endX, endY) {
    this.startX = startX;
    this.startY = startY;
    this.controlX1 = controlX1;
    this.controlY1 = controlY1;
    this.controlX2 = controlX2;
    this.controlY2 = controlY2;
    this.endX = endX;
    this.endY = endY;
    null;
  }

  ScalableBezier.prototype.clone = function() {
    return new ScalableBezier(this.startX, this.startY, this.controlX1, this.controlY1, this.controlX2, this.controlY2, this.endX, this.endY);
  };

  ScalableBezier.prototype.scale = function(scaleX, scaleY) {
    var newBezier;
    newBezier = this.clone();
    newBezier.mutateScale(scaleX, scaleY);
    return newBezier;
  };

  ScalableBezier.prototype.mutateScale = function(scaleX, scaleY) {
    this.startX *= scaleX;
    this.startY *= scaleY;
    this.controlX1 *= scaleX;
    this.controlY1 *= scaleY;
    this.controlX2 *= scaleX;
    this.controlY2 *= scaleY;
    this.endX *= scaleX;
    return this.endY *= scaleY;
  };

  ScalableBezier.prototype.applyToCanvas = function(context, offsetX, offsetY) {
    if (offsetX == null) {
      offsetX = 0;
    }
    if (offsetY == null) {
      offsetY = 0;
    }
    context.lineTo(offsetX + this.startX, offsetY + this.startY);
    return context.bezierCurveTo(this.controlX1 + offsetX, this.controlY1 + offsetY, this.controlX2 + offsetX, this.controlY2 + offsetY, this.endX + offsetX, this.endY + offsetY);
  };

  ScalableBezier.prototype.renderPoints = function(context, offsetX, offsetY, color) {
    if (offsetX == null) {
      offsetX = 0;
    }
    if (offsetY == null) {
      offsetY = 0;
    }
    if (color == null) {
      color = "#F00";
    }
    context.fillStyle = color;
    context.fillRect(this.startX + offsetX, this.startY + offsetY, 5, 5);
    context.fillRect(this.controlX1 + offsetX, this.controlY1 + offsetY, 5, 5);
    context.fillRect(this.controlX2 + offsetX, this.controlY2 + offsetY, 5, 5);
    return context.fillRect(this.endX + offsetX, this.endY + offsetY, 5, 5);
  };

  ScalableBezier.prototype.reverse = function() {
    var newBezier;
    newBezier = this.clone();
    newBezier.mutableReverse();
    return newBezier;
  };

  ScalableBezier.prototype.mutableReverse = function() {
    var tmp;
    tmp = this.startX;
    this.startX = this.endX;
    this.endX = tmp;
    tmp = this.startY;
    this.startY = this.endY;
    this.endY = tmp;
    tmp = this.controlX1;
    this.controlX1 = this.controlX2;
    this.controlX2 = tmp;
    tmp = this.controlY1;
    this.controlY1 = this.controlY2;
    return this.controlY2 = tmp;
  };

  return ScalableBezier;

})();

module.exports = ScalableBezier;


},{}],14:[function(require,module,exports){
var BackgroundStrategy, SolidBackground,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BackgroundStrategy = require('./backgroundStrategy');

SolidBackground = (function(superClass) {
  extend(SolidBackground, superClass);

  function SolidBackground(color) {
    SolidBackground.__super__.constructor.call(this);
    this.color = color;
    this.ready = true;
  }

  SolidBackground.prototype.renderToCanvas = function(element, context, dTime) {
    var dim;
    if (dTime == null) {
      dTime = 0;
    }
    dim = this.getDimensions(element);
    context.fillStyle = this.color;
    return context.fillRect(0, 0, dim.width(), dim.height());
  };

  return SolidBackground;

})(BackgroundStrategy);

module.exports = SolidBackground;


},{"./backgroundStrategy":8}],15:[function(require,module,exports){
var Vector,
  slice = [].slice;

Vector = (function() {
  function Vector() {
    var values;
    values = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    this.values = values;
    this.values;
  }

  Vector.prototype.clone = function() {
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(Vector, this.values, function(){});
  };

  Vector.prototype.reverse = function() {
    return this.scale(-1);
  };

  Vector.prototype.scale = function(scalar) {
    var vec;
    vec = this.clone();
    vec.mutScale(scalar);
    return vec;
  };

  Vector.prototype.update = function() {
    var values;
    values = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    this.values = values;
    return this;
  };

  Vector.prototype.setX = function(val) {
    return this.values[0] = val;
  };

  Vector.prototype.setY = function(val) {
    return this.values[1] = val;
  };

  Vector.prototype.setZ = function(val) {
    return this.values[2] = val;
  };

  Vector.prototype.mutScale = function(scalar) {
    return this.values = this.values.map(function(x) {
      return x * scalar;
    });
  };

  Vector.prototype.equals = function(other) {
    var i, idx, len, ref, val;
    if (other.values.length !== this.values.length) {
      return false;
    }
    ref = this.values;
    for (idx = i = 0, len = ref.length; i < len; idx = ++i) {
      val = ref[idx];
      if (other.values[idx] !== val) {
        return false;
      }
    }
    return true;
  };

  Vector.prototype.x = function() {
    if (this.values.length > 0) {
      return this.values[0];
    }
    return null;
  };

  Vector.prototype.y = function() {
    if (this.values.length > 1) {
      return this.values[1];
    }
    return null;
  };

  Vector.prototype.z = function() {
    if (this.values.length > 2) {
      return this.values[2];
    }
    return null;
  };

  return Vector;

})();

module.exports = Vector;


},{}],16:[function(require,module,exports){
var BackgroundStrategy, ImageBackground, VideoBackground,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BackgroundStrategy = require('./backgroundStrategy');

ImageBackground = require('./imageBackground');

VideoBackground = (function(superClass) {
  extend(VideoBackground, superClass);

  function VideoBackground(baseurl) {
    this.debug = false;
    VideoBackground.__super__.constructor.call(this);
    this.requiresRedrawing = true;
    if (!this.detectVideoSupport()) {
      throw "No HTML5 video support detected";
    }
    this.fallback = this.createImageBackground(baseurl + ".jpg");
    this.video = this.createVideoElement(baseurl);
  }

  VideoBackground.prototype.createImageBackground = function(imageurl) {
    var fallback;
    fallback = new ImageBackground(imageurl);
    fallback.setCallback((function(_this) {
      return function() {
        if (_this.callback !== null) {
          return _this.callback();
        }
      };
    })(this));
    return fallback;
  };

  VideoBackground.prototype.createVideoElement = function(baseurl) {
    var video;
    video = document.createElement('video');
    video.addEventListener('playing', (function(_this) {
      return function() {
        return _this.setReady();
      };
    })(this));
    this.setAttribute(video, 'poster', baseurl + ".jpg");
    this.setAttribute(video, 'autoplay', 'autoplay');
    this.setAttribute(video, 'loop', 'loop');
    video.appendChild(this.createSource(baseurl + ".webm", 'video/webm; codecs="vp8.0, vorbis"'));
    video.appendChild(this.createSource(baseurl + ".ogv", 'video/ogg; codecs="theora, vorbis"'));
    video.appendChild(this.createSource(baseurl + ".mp4", 'video/mp4; codecs="avc1.4D401E, mp4a.40.2"'));
    return video;
  };

  VideoBackground.prototype.setAttribute = function(element, name, value) {
    var attr;
    attr = document.createAttribute(name);
    attr.value = value;
    return element.attributes.setNamedItem(attr);
  };

  VideoBackground.prototype.createSource = function(path, type) {
    var source;
    source = document.createElement('source');
    this.setAttribute(source, 'type', type);
    this.setAttribute(source, 'src', path);
    return source;
  };

  VideoBackground.prototype.detectVideoSupport = function() {
    var basicSupport, element, iOS;
    element = document.createElement('video');
    basicSupport = typeof element.play === 'function' && typeof requestAnimationFrame === 'function';
    iOS = /iPad|iPhone|iPod/.test(navigator.platform);
    return basicSupport && !iOS;
  };

  VideoBackground.prototype.renderToCanvas = function(element, context, dTime) {
    var box, dims, ref;
    if (dTime == null) {
      dTime = 0;
    }
    if (!this.ready) {
      return (ref = this.fallback) != null ? ref.renderToCanvas(element, context, dTime) : void 0;
    }
    dims = this.getDimensions(element);
    box = this.getRenderBox(dims, this.video);
    if (this.debug) {
      console.log(dims, box, element, context, this.video);
      this.debug = false;
    }
    return context.drawImage(this.video, box.source.x, box.source.y, box.dims.width, box.dims.height, 0, 0, dims.vector.values[0], dims.vector.values[1]);
  };

  VideoBackground.prototype.setReady = function() {
    this.ready = true;
    if (this.callback !== null) {
      return this.callback();
    }
  };

  VideoBackground.prototype.setCallback = function(fn) {
    return this.callback = fn;
  };

  return VideoBackground;

})(BackgroundStrategy);

module.exports = VideoBackground;


},{"./backgroundStrategy":8,"./imageBackground":11}],17:[function(require,module,exports){
var AnimationFrameDispatch, BackgroundFactory, BackgroundStrategy, BackgroundTransition, BezierMask, ElementDimensions, Layer, RAFPatch, TemporaryCanvas, WibblyElement,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

AnimationFrameDispatch = require('./AnimationFrameDispatch');

BezierMask = require('./BezierMask');

BackgroundStrategy = require('./backgroundStrategy');

ElementDimensions = require('./ElementDimensions');

TemporaryCanvas = require('./TemporaryCanvas');

Layer = require('./Layer');

BackgroundTransition = require('./backgroundTransition');

BackgroundFactory = require('./BackgroundFactory');

RAFPatch = require('./raf');

RAFPatch();

WibblyElement = (function() {
  WibblyElement.FrameDispatch = new AnimationFrameDispatch();

  function WibblyElement(element1) {
    this.element = element1;
    this.draw = bind(this.draw, this);
    this.redraw_needed = false;
    this.transitions = [];
    this.bgFactory = new BackgroundFactory();
    this.bgFactory.setFallbackColor(this.fallbackColor(this.element));
    this.compositeSupported = this.isCompositeSupported();
    this.element.style.position = 'relative';
    this.bezierMask = BezierMask.fromElementAttributes(this.element);
    this.loadBackground(this.element);
    this.createCanvas();
    this.removeLoadingClass(this.element);
    WibblyElement.FrameDispatch.register(this);
  }

  WibblyElement.prototype.fallbackColor = function(element) {
    return element.getAttribute('data-fallback-color') || '#000';
  };

  WibblyElement.prototype.removeLoadingClass = function(element) {
    return element.className = element.className.replace(/\bwib-loading\b/, '');
  };

  WibblyElement.prototype.isCompositeSupported = function() {
    var ctx, test;
    test = document.createElement('canvas');
    ctx = test.getContext('2d');
    ctx.globalCompositeOperation = 'destination-in';
    return ctx.globalCompositeOperation === 'destination-in';
  };

  WibblyElement.prototype.loadBackground = function(element) {
    var attribute;
    attribute = element.attributes.getNamedItem('data-background');
    if (attribute === null) {
      throw "missing required data-background attribute";
    }
    this.background = this.bgFactory.create(attribute.value);
    return this.background.setCallback((function(_this) {
      return function() {
        return _this.redraw_needed = true;
      };
    })(this));
  };

  WibblyElement.prototype.createCanvas = function() {
    this.canvas = document.createElement('canvas');
    this.context = this.canvas.getContext('2d');
    this.canvas.style.position = "absolute";
    this.canvas.style.left = 0;
    this.canvas.style.top = 0;
    this.canvas.style.zIndex = -1;
    return this.element.appendChild(this.canvas);
  };

  WibblyElement.prototype.getElementDimensions = function(element) {
    if (this.elementDims == null) {
      this.elementDims = new ElementDimensions;
    }
    return this.elementDims.updateFromElement(element);
  };

  WibblyElement.prototype.resize = function() {
    var dims;
    dims = this.getElementDimensions(this.element);
    this.canvas.style.top = dims.topMargin + "px";
    if (this.tmpCanvas == null) {
      this.tmpCanvas = new TemporaryCanvas;
    }
    this.tmpCanvas.copyCanvas(this.canvas);
    this.canvas.width = dims.width;
    this.canvas.height = dims.totalHeight;
    this.canvas.style.width = dims.width + "px";
    this.canvas.style.height = dims.totalHeight + "px";
    return this.tmpCanvas.restoreToContext(this.context);
  };

  WibblyElement.prototype.isVisible = function() {
    if (this.canvasLayer == null) {
      this.canvasLayer = new Layer(0, 0, 0, 0);
    }
    this.canvasLayer.updateFromElement(this.canvas);
    return Layer.Viewport().intersects(this.canvasLayer);
  };

  WibblyElement.prototype.needsAnimation = function() {
    if (!this.isVisible()) {
      return false;
    }
    if (this.redraw_needed) {
      return true;
    }
    if (this.background.requiresRedrawing) {
      return true;
    }
    if (this.transitions.length > 0) {
      return true;
    }
    return false;
  };

  WibblyElement.prototype.draw = function(timestamp) {
    var dims;
    if (timestamp == null) {
      timestamp = 0;
    }
    this.drawing = true;
    this.redraw_needed = false;
    dims = this.getElementDimensions(this.element);
    this.background.renderToCanvas(this.canvas, this.context, timestamp);
    if (this.compositeSupported) {
      this.bezierMask.drawClippingShape(this.context, dims);
    }
    this.processTransitions(dims, timestamp);
    return this.drawing = false;
  };

  WibblyElement.prototype.processTransitions = function(dimensions, timestamp) {
    var i, len, old_required_animation, ref, transition;
    if (this.transitions.length === 0) {
      return;
    }
    if (timestamp === 0) {
      return;
    }
    ref = this.transitions;
    for (i = 0, len = ref.length; i < len; i++) {
      transition = ref[i];
      transition.process(this.canvas, this.context, dimensions, timestamp);
    }
    old_required_animation = this.background.requiresRedrawing;
    while (true) {
      if (this.transitions.length === 0) {
        break;
      }
      if (this.transitions[this.transitions.length - 1].finished) {
        this.background = this.transitions.pop().background;
      } else {
        break;
      }
    }
    if (!old_required_animation && this.background.requiresRedrawing) {
      return this.redraw_needed = true;
    }
  };

  WibblyElement.prototype.changeBackground = function(backgroundString, duration) {
    var error, error1, new_background, transition;
    if (duration == null) {
      duration = 0;
    }
    try {
      new_background = this.bgFactory.create(backgroundString);
    } catch (error1) {
      error = error1;
      console.log(error);
      return;
    }
    if (duration === 0) {
      this.background = new_background;
    } else {
      transition = new BackgroundTransition(new_background, duration);
      this.transitions.unshift(transition);
    }
    return this.redraw_needed = true;
  };

  return WibblyElement;

})();

window.WibblyElement = module.exports = WibblyElement;


},{"./AnimationFrameDispatch":2,"./BackgroundFactory":3,"./BezierMask":4,"./ElementDimensions":5,"./Layer":6,"./TemporaryCanvas":7,"./backgroundStrategy":8,"./backgroundTransition":9,"./raf":12}]},{},[17]);
