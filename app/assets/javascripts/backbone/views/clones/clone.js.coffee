class Wiki.Views.Clone extends Backbone.View
  el:  '#clone'
  template : JST['backbone/templates/clone']

  initialize: ->
    self = @
    @model.fetch(
      success: -> self.render()
    )

  render: ->
    debugger
    $(@el).append(@template(@model.toJSON()))
