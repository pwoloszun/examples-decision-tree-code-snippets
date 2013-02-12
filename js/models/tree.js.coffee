class DecisionTree.Models.Tree extends Backbone.Model

  urlRoot: "/decision-trees"

  @find: (id, callback) ->
    throw("Error tree id is undefined") unless id?
    tree = new DecisionTree.Models.Tree(id: id)
    tree.fetch(
      success: (that, nodesData) ->
        tree._buildTree(nodesData)
        callback(tree)
      error: ->
        throw("Error while fetching Decison Tree id: #{id}")
    )

  initialize: ->
    @.set(root: new DecisionTree.Models.Node()) unless @.id?

  removeNode: (node) ->
    @._removeRecursively(node, @.get("root"))

  _removeRecursively: (nodeToRemove, currentNode) ->
    childrenNodes = _(currentNode.get("children")).chain()
    if childrenNodes.include(nodeToRemove).value()
      currentNode.set("children", childrenNodes.without(nodeToRemove).value())
    else
      childrenNodes.each((childNode) =>
        @._removeRecursively(nodeToRemove, childNode)
      )

  _buildTree: (allNodesData) ->
    _(allNodesData).each((nodeData) =>
      _(nodeData).extend(treeId: @.id)
    )
    rootData = _(allNodesData).find((nodeData) ->
      nodeData.parentId == null
    )
    root = @._buildNodeRecursively(rootData, allNodesData)
    @.set(root: root)

  _buildNodeRecursively: (parentNodeData, allNodesData) ->
    childrenData = _(allNodesData).select((node) ->
      node.parentId == parentNodeData.id
    )
    children = _(childrenData).map((childData) =>
      @._buildNodeRecursively(childData, allNodesData)
    )
    attrs = _(parentNodeData).extend(children: children)
    new DecisionTree.Models.Node(parentNodeData)
