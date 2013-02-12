class DecisionTree.Models.Node extends Backbone.Model

  url: ->
    baseUrl = "/decision-trees/#{encodeURIComponent(@.get("treeId"))}/nodes"
    if @.isNew()
      baseUrl
    else
      "#{baseUrl}/#{encodeURIComponent(@.id)}"

  defaults:
    text: "[wprowadź treść procedury]"
    children: []

  initialize: ->
    @.link = new DecisionTree.Models.Link(@.get("link"))

  isRoot: ->
    !@.get("parentId")?

  isType: (type) ->
    @.link.get("type") == type

  canAddChildOn: (type) ->
    !_(@.get("children")).any((child) ->
      child.isType(type)
    )

  addChild: (type, options) ->
    return unless @.canAddChildOn(type)
    childNode = new DecisionTree.Models.Node(
      treeId: @.get("treeId")
      parentId: @.id
      children: []
      link:
        type: type
    )
    childNode.save({},
      success: (node, data) =>
        node.id = data.id
        @.get("children").push(node)
        options.success.apply(@, arguments)
      error: options.error
    )

  isLeaf: ->
    @.get("children").length == 0

  leafsCount: ->
    if @.isLeaf()
      1
    else
      children = _(@.get("children"))
      children.reduce((sum, child) ->
        sum + child.leafsCount()
      , 0)
