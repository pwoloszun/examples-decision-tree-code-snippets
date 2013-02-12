class DecisionTree.Models.Link extends Backbone.Model

  initialize: (params) ->
    unless @.get("text")?
      @.set(text: if @.get("type") == "left" then "Tak" else "Nie")

  isDefined: ->
    type = @.get("type")
    text = @.get("text")
    _(["left", "right"]).include(type) && !_(text).isBlank()
