class DecisionTree.Views.TextEditorView extends Backbone.View

  template: template: JST["tree_editor_view"]

  events:
    "mousedown > .dt-text-editor": "onMouseDown"
    "mousemode > .dt-text-editor": "onMouseMove"
    "click .dt-save": "saveChanges"
    "click .dt-cancel": "cancelChanges"

  initialize: (params) ->
    @.nodeView = params.nodeView

  render: ->
    @.$el.append(@.template(@.nodeView.model.toJSON()))

  show: ->
    @._getTextEditor().show()

  hide: ->
    @._getTextEditor().hide()

  focus: ->
    @._getTextarea().focus()

  saveChanges: (event) ->
    @.nodeView.update(text: @._getTextarea().val())

  cancelChanges: (event) ->
    @.nodeView.cancelChanges()

  onMouseDown: (event) ->
    event.stopPropagation()

  onMouseMove: (event) ->
    event.stopPropagation()

  _getTextEditor: ->
    @.$el.find("> .dt-text-editor")

  _getTextarea: ->
    @.$el.find("> .dt-text-editor textarea")
