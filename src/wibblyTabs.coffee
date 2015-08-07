
class @WibblyTabs


  constructor : (@$, @wibblyContainer) ->
    # set up tabs
    @tabs = @wibblyContainer.find('.wibbly-tab')

    self = @
    @tabs.each (idx, el) ->
      @.data('wibblytabs', self)
      @.data('tabindex', idx)

    @tabs.on 'click', ->
      wibblyTabsObj = @.data 'wibblytabs'
      wibblyTabsObj.setTab @.data('tabindex')

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
    @wibbly.adjustCanvas() # adjust canvas to newly sized content
    
    # set new background on wibblyElement
    imagedata = @currentElement.data 'background'
    @wibbly.changeBackground "image #{imagedata}", 1000
