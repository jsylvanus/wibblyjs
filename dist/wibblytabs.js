(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __slice = [].slice;

  this.objectCycler = (function() {
    function objectCycler(data) {
      if (data == null) {
        data = [];
      }
      this.last = __bind(this.last, this);
      this.first = __bind(this.first, this);
      this.at = __bind(this.at, this);
      this.prev = __bind(this.prev, this);
      this.next = __bind(this.next, this);
      this.count = __bind(this.count, this);
      this.position = __bind(this.position, this);
      this.current = __bind(this.current, this);
      this.setPosition = __bind(this.setPosition, this);
      if (typeof data === 'string') {
        if (typeof jQuery !== 'undefined') {
          data = jQuery(data).toArray();
        } else {
          throw 'jQuery must be available to construct with a selector.';
        }
      }
      this.data = data;
      this.index = 0;
    }

    objectCycler.prototype.setPosition = function(position) {
      var idx;
      idx = position - 1;
      if (idx < 0 || idx > this.data.length - 1) {
        throw new Error('index out of bounds');
      }
      return this.index = idx;
    };

    objectCycler.prototype.current = function() {
      return this.data[this.index];
    };

    objectCycler.prototype.position = function() {
      if (this.data.length === 0) {
        return 0;
      }
      return this.index + 1;
    };

    objectCycler.prototype.count = function() {
      return this.data.length;
    };

    objectCycler.prototype.next = function() {
      var nextIndex;
      if (this.data.length === 0) {
        return null;
      }
      nextIndex = this.index;
      nextIndex += 1;
      if (nextIndex === this.data.length) {
        nextIndex = 0;
      }
      this.index = nextIndex;
      return this.current();
    };

    objectCycler.prototype.prev = function() {
      var nextIndex;
      if (this.data.length === 0) {
        return null;
      }
      nextIndex = this.index;
      nextIndex -= 1;
      if (nextIndex < 0) {
        nextIndex = this.data.length - 1;
      }
      this.index = nextIndex;
      return this.current();
    };

    objectCycler.prototype.at = function(idx) {
      idx -= 1;
      if (idx < 0 || idx > this.data.length - 1) {
        return null;
      }
      return this.data[this.index = idx];
    };

    objectCycler.prototype.first = function() {
      if (this.data.length === 0) {
        return null;
      }
      return this.data[this.index = 0];
    };

    objectCycler.prototype.last = function() {
      if (this.data.length === 0) {
        return null;
      }
      return this.data[this.index = this.data.length - 1];
    };

    objectCycler.prototype._peekFn = function() {
      var el, fname, idx, params;
      fname = arguments[0], params = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      idx = this.index;
      el = this[fname](params);
      this.index = idx;
      return el;
    };

    objectCycler.prototype.peekAt = function(idx) {
      return this._peekFn('at', idx);
    };

    objectCycler.prototype.peekNext = function() {
      return this._peekFn('next');
    };

    objectCycler.prototype.peekPrev = function() {
      return this._peekFn('prev');
    };

    objectCycler.prototype.peekFirst = function() {
      return this._peekFn('first');
    };

    objectCycler.prototype.peekLast = function() {
      return this._peekFn('last');
    };

    return objectCycler;

  })();

}).call(this);
;(function() {
  this.WibblyTabs = (function() {
    function WibblyTabs($, wibblyContainer) {
      var self,
        _this = this;
      this.$ = $;
      this.wibblyContainer = wibblyContainer;
      this.tabs = this.wibblyContainer.find('.wibbly-tab');
      self = this;
      this.tabs.each(function(idx, el) {
        _this.$(el).data('wibblytabs', _this);
        return _this.$(el).data('tabindex', idx);
      });
      this.tabs.on('click', function(evt) {
        var wibblyTabsObj;
        evt.stopPropagation();
        evt.preventDefault();
        wibblyTabsObj = self.$(this).data('wibblytabs');
        return wibblyTabsObj.setTab(self.$(this).data('tabindex'));
      });
      this.wibbly = new WibblyElement(this.wibblyContainer.get(0));
      this.contentContainer = this.wibblyContainer.find('.tab-content');
      this.setTab(0);
    }

    WibblyTabs.prototype.setTab = function(index) {
      var imagedata, newTab, targetElement;
      newTab = this.tabs.eq(index);
      this.tabs.removeClass('active');
      newTab.addClass('active');
      targetElement = this.$(newTab.attr('href'));
      this.currentElement = targetElement.clone();
      this.contentContainer.empty().append(this.currentElement);
      this.wibbly.adjustCanvas();
      imagedata = this.currentElement.data('background');
      return this.wibbly.changeBackground(imagedata, 1000);
    };

    return WibblyTabs;

  })();

}).call(this);
