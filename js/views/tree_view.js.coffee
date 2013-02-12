class DecisionTree.Views.TreeView extends Backbone.View

  template: JST["tree_view"]

  events:
    "click": "closeAllContextMenus"

  initialize: ->
    @._setNodes()

  render: ->
    sliderPosition = @._getSliderPosition()
    @.$el.html(@.template)
    @.rootNode.setElement(@._getSlider())
    @.rootNode.render()
    @._setSliderPosition(sliderPosition)
    @._adjustSize()
    @._setDifferenceBetweenTreeAndViewport()
    if @._treeBiggerThanViewport()
      @._makeSliderDraggable()

  closeAllContextMenus: (event) =>
    event.preventDefault()
    event.stopPropagation()
    @._allNodeViews.each((nodeView) ->
      nodeView.closeContextMenu()
    )

  _treeBiggerThanViewport: ->
    @._sizeDifference.horizontal > 0 || @._sizeDifference.vertical > 0

  _setDifferenceBetweenTreeAndViewport: ->
    viewport = @.$el.find(".dt-viewport")
    slider = @._getSlider()
    @._sizeDifference =
      horizontal: slider.outerWidth(true) - viewport.width()
      vertical: slider.outerHeight(true) - viewport.height()

  _makeSliderDraggable: ->
    @._getSlider().addClass("dt-dragable")
    @.delegateEvents(
      "click": "closeAllContextMenus"
      "mousedown .dt-slider": "_sliderMouseDown"
      "mousemove .dt-slider": "_sliderMouseMove"
    )

  _adjustSize: ->
    leafsCount = @.model.get("root").leafsCount()
    @._getSlider().width(leafsCount * DecisionTree.Views.NodeView.WIDTH)

  _getSlider: ->
    @.$el.find("> .dt-viewport > .dt-slider")

  _sliderMouseDown: (event) =>
    event.preventDefault()
    slider = @._getSlider()
    @._sliderStartPosition = slider.position()
    @._mousePos =
      x: event.clientX
      y: event.clientY

  _sliderMouseMove: (event) =>
    event.preventDefault()
    if @._leftButtonPressed(event) && @._sliderStartPosition?
      @._moveSlider(event)

  _moveSlider: (event) ->
    leftPos = @._sliderStartPosition.left + (event.clientX - @._mousePos.x)
    topPos = @._sliderStartPosition.top + (event.clientY - @._mousePos.y)
    leftPos = Math.max(Math.min(0, leftPos), Math.min(0, -@._sizeDifference.horizontal))
    topPos = Math.max(Math.min(0, topPos), Math.min(0, -@._sizeDifference.vertical))
    @._getSlider().css(
      left: leftPos
      top: topPos
    )

  _leftButtonPressed: (event) ->
    if event.buttons?
      event.buttons == 1
    else if event.which?
      event.which == 1
    else
      event.button == 1

  _rerender: ->
    @._setNodes()
    @.render()

  _setNodes: ->
    @.rootNode = new DecisionTree.Views.NodeView(model: @.model.get("root"))
    @._observeAllNodeViews()

  _observeAllNodeViews: ->
    @._allNodeViews = _(@.rootNode.getNodes()).chain().flatten()
    @._allNodeViews.each((nodeView) =>
      nodeView.on(
        openContextMenu: @._onContextMenuOpen
        nodeRemoved: @._nodeRemoved
        nodeAdded: @._nodeAdded
      )
    )

  _onContextMenuOpen: (currentNodeView) =>
    @._allNodeViews.each((nodeView) ->
      nodeView.closeContextMenu() if currentNodeView isnt nodeView
    )

  _nodeRemoved: (node) =>
    @.model.removeNode(node)
    @._rerender()

  _nodeAdded: =>
    @._rerender()

  _getSliderPosition: ->
    slider = @._getSlider()
    slider.position() || {top: 0, left: 0}

  _setSliderPosition: (sliderPosition) ->
    slider = @._getSlider()
    slider.css(sliderPosition)
