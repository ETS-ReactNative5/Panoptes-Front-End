# @cjsx React.DOM

React = require 'react'
Markdown = require './markdown'
alert = require '../lib/alert'

NOOP = Function.prototype

module.exports = React.createClass
  displayName: 'MarkdownEditor'

  getDefaultProps: ->
    placeholder: ''
    value: ''
    onChange: NOOP

  getInitialState: ->
    previewing: false

  render: ->
    previewing = @props.previewing ? @state.previewing

    <div className={['markdown-editor', @props.className].join ' '} data-previewing={@state.previewing or null}>
      {@transferPropsTo <textarea className="markdown-editor-input" placeholder={@props.placeholder} value={@props.value} onChange={@props.onChange} />}

      <Markdown className="markdown-editor-preview">{@props.value}</Markdown>

      <div className="markdown-editor-controls">
        <button type="button" onClick={@handlePreviewToggle}>
          {if previewing
            <i className="fa fa-pencil fa-fw"></i>
          else
            <i className="fa fa-eye fa-fw"></i>}
        </button>

        <br />

        <button type="button" onClick={@handleHelpRequest}>
          <i className="fa fa-question fa-fw"></i>
        </button>
      </div>
    </div>

  handlePreviewToggle: (e) ->
    @setState previewing: not @state.previewing

  handleHelpRequest: ->
    alert <p>TODO: Show a dialog with Markdown help.</p>
