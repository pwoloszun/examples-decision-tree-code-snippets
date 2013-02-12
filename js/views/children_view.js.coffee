class DecisionTree.Views.ChildrenView extends Backbone.View

  template: JST["children_view"]

  initialize: ->
    @.model = [] unless @.model?
    @._setChildrenNodes()
    @.linksView = new DecisionTree.Views.LinkView(model: @.model)

  render: ->
    if @.hasChildren()
      @.$el.append(@.template)
      @.linksView.setElement(@.$el.find("> .dt-children"))
      @.linksView.render()
      for type, childNodeView of @._childrenNodes
        childEl = @.$el.find("> .dt-children > .dt-#{type}-child")
        childNodeView.setElement(childEl)
        childNodeView.render()

  hasChildren: ->
    @.model.length > 0

  getNodes: ->
    nodes = []
    _(@._childrenNodes).each((nodeView) ->
      nodes.push(nodeView.getNodes())
    )
    nodes

  _setChildrenNodes: () ->
    @._childrenNodes = {}
    for type in ["left", "right"]
      child = _(@.model).find((node) ->
        node.isType(type)
      )
      @._childrenNodes[type] = new DecisionTree.Views.NodeView(model: child) if child?
