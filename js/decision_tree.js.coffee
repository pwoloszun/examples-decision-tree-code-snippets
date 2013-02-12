window.DecisionTree =
  Models: {}
  Collections: {}
  Views: {}
  init: ->
    $(".dt-decision-tree").each(->
      treeEl = $(@)
      treeId = treeEl.data("treeId")
      DecisionTree.Models.Tree.find(treeId, (tree) ->
        treeView = new DecisionTree.Views.TreeView(
          el: treeEl
          model: tree
        )
        treeView.render()
      )
    )

$(document).ready(->
  DecisionTree.init()
)
