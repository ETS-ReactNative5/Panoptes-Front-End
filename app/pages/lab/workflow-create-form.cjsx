React = require 'react'
createReactClass = require 'create-react-class'
counterpart = require 'counterpart'

WorkflowCreateForm = createReactClass
  getDefaultProps: ->
    onCancel: ->
    onSubmit: ->
    onSuccess: ->
    project: null
    workflowToClone: null
    workflowActiveStatus: false

  getInitialState: ->
    busy: false
    error: null

  handleSubmit: (e) ->
    e.preventDefault()

    @setState
      busy: true
      error: null

    workflowToClone = @props.workflowToClone

    newWorkflow =
      display_name: @refs.newDisplayName.value
      primary_language: workflowToClone?.primary_language || @props.project.primary_language
      steps: workflowToClone?.steps ? undefined
      tasks: workflowToClone?.tasks ? {}
      first_task: workflowToClone?.first_task ? ''
      configuration: workflowToClone?.configuration ? {}
      retirement: workflowToClone?.retirement ? {}
      active: @props.workflowActiveStatus ? false
      grouped: workflowToClone?.grouped ? false
      prioritized: workflowToClone?.prioritized ? false

    awaitSubmission = @props.onSubmit(@props.project.id, newWorkflow)

    Promise.resolve(awaitSubmission)
      .then (result) =>
        @setState busy: false
        @props.onSuccess result
      .catch (error) =>
        @setState {error}

  render: ->
    <form onSubmit={@handleSubmit} style={maxWidth: '90vw', width: '30ch'}>
      <label>
        <span className="form-label">New Workflow Title</span>
        <br />
        <input className="standard-input full" type="text" ref="newDisplayName" defaultValue="new workflow title" autoFocus required />
      </label>
      <br />
      {if @state.error?
        <p className="form-help error">{@state.error.toString()}</p>}
      <p style={textAlign: 'center'}>
        <button type="button" className="minor-button" disabled={@state.busy} onClick={@props.onCancel}>Cancel</button>{' '}
        <button type="submit" className="major-button" disabled={@state.busy}>Add</button>
      </p>
    </form>

module.exports = WorkflowCreateForm
