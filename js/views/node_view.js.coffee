class DecisionTree.Views.NodeView extends Backbone.View

  @WIDTH = 220

  template: _.template(JST["node_view"])

  events:
    "contextmenu > .dt-node": "onNodeRightClick"

  initialize: ->
    @.childrenView = new DecisionTree.Views.ChildrenView(model: @.model.get("children"))
    @.contextMenuView = new DecisionTree.Views.ContextMenuView(nodeView: @)
    @.textEditorView = new DecisionTree.Views.TextEditorView(nodeView: @)

  render: ->
    @.$el.html(@.template(@.model.toJSON()))
    @.childrenView.setElement(@.el)
    @.childrenView.render()
    nodeEl = @._getNode()
    @.contextMenuView.setElement(nodeEl)
    @.contextMenuView.render()
    @.textEditorView.setElement(nodeEl.find("> .dt-node-inner"))
    @.textEditorView.render()

  editText: ->
    @.$el.find("> .dt-node .dt-text").hide()
    @.textEditorView.show()
    @.textEditorView.focus()

  update: (params) ->
    newText = _(params.text).trim()
    if newText != @.model.get("text")
      @.model.save({text: newText},
        success: (node, data) =>
          @.textEditorView.hide()
          @.$el.find("> .dt-node .dt-text").text(newText).show()
        error: (node) ->
          alert("Error while updating Node with id: #{node.id}")
      )
    else
      @.cancelChanges()

  cancelChanges: ->
    @.textEditorView.hide()
    @.$el.find("> .dt-node .dt-text").show()

  addChild: (type) ->
    @.model.addChild(type,
      success: (node) =>
        @.trigger("nodeAdded")
      error: (node) =>
        alert("Error while trying to add #{type} Child to Node id: #{@.id}")
    )

  remove: ->
    @.model.destroy(
      success: (node) =>
        @.trigger("nodeRemoved", node)
      error: (node) ->
        alert("Error while trying to destroy Node id: #{node.id}")
    )

  onNodeRightClick: (event) ->
    event.preventDefault()
    @.showContextMenu(event)

  offset: ->
    @._getNode().offset()

  showContextMenu: (event) ->
    @.contextMenuView.show(event)
    @.trigger("openContextMenu", @)

  closeContextMenu: ->
    @.contextMenuView.hide()

  getNodes: ->
    nodes = @.childrenView.getNodes()
    nodes.push(@)
    nodes

  _getNode: ->
    @.$el.find("> .dt-node")
