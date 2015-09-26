WibblyElement = require('./wibblyElement')

class WibblyTabs

  constructor : (@$, @wibblyContainer) ->
    # set up tabs
    @tabs = @wibblyContainer.find('.wibbly-tab')

    self = @
    @tabs.each (idx, el) =>
      @$(el).data('wibblytabs', @)
      @$(el).data('tabindex', idx)

    @tabs.on 'click', (evt) ->
      evt.stopPropagation()
      evt.preventDefault()
      wibblyTabsObj = self.$(@).data 'wibblytabs'
      wibblyTabsObj.setTab self.$(@).data('tabindex')

    # construct wibblyElement
    @wibbly = new WibblyElement( @wibblyContainer.get(0) )

    @contentContainer = @wibblyContainer.find('.tab-content')
    @setTab(0)


  setTab : (index) ->
    newTab = @tabs.eq(index)

    # swap active attribute
    @tabs.removeClass('active')
    newTab.addClass('active')

    # replace current item with correct tab content
    targetElement = @$ newTab.attr('href')
    @currentElement = targetElement.clone()
    @contentContainer.empty().append(@currentElement)
    @wibbly.redraw_needed = yes
    
    # set new background on wibblyElement
    imagedata = @currentElement.data 'background'
    @wibbly.changeBackground imagedata, 1000

window.WibblyTabs = module.exports = WibblyTabs
