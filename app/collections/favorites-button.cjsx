React = require 'react'
apiClient = require '../api/client'
auth = require '../api/auth'
getFavoritesName = require './get-favorites-name'
alert = require '../lib/alert'
SignInPrompt = require '../partials/sign-in-prompt'
PromiseRenderer = require '../components/promise-renderer'

module?.exports = React.createClass
  displayName: 'CollectionFavoritesButton'

  propTypes:
    subject: React.PropTypes.object # a subject response from panoptes
    project: React.PropTypes.object # a project response from panoptes

  getDefaultProps: ->
    subject: null
    project: null

  getInitialState: ->
    favoritesPromise: null
    favoritedPromise: null
    favorites: {}
    favorited: false

  promptToSignIn: ->
    alert (resolve) ->
      <SignInPrompt onChoose={resolve}>
        <p>You must be signed in to save your favorites.</p>
      </SignInPrompt>

  findFavoriteCollection: ->
    apiClient.type('collections').get({project_id: @props.project?.id, favorite: true})
      .then ([favorites]) -> if favorites? then favorites else null

  findSubjectInCollection: (favorites) ->
    if favorites?
      favorites.get('subjects', id: @props.subject.id)
        .then ([subject]) -> subject?
    else
      Promise.resolve(false)

  componentWillMount: ->
    # see if the subject is in the project's favorites collection
    # to see if it's favorites
    favoritesPromise = @findFavoriteCollection()
    favoritedPromise = favoritesPromise.then (favs) => @findSubjectInCollection(favs)

    @setState {favoritesPromise, favoritedPromise}

  addSubjectTo: (collection) ->
    collection.addLink('subjects', [@props.subject.id.toString()])
      .then (collection) => @setState favoritedPromise: Promise.resolve(true)

  removeSubjectFrom: (collection) ->
    collection.removeLink('subjects', [@props.subject.id.toString()])
      .then (collection) => @setState favoritedPromise: Promise.resolve(false)

  createFavorites: (user) ->
    display_name = getFavoritesName(@props.project)
    project = @props.project?.id
    subjects = [@props.subject.id]
    favorite = true

    links = {subjects}
    links.project = project if project?
    collection = {favorite, display_name, links}

    apiClient.type('collections').create(collection).save().then =>
      @setState favoritedPromise: Promise.resolve(true)

  toggleFavorite: ->
    auth.checkCurrent().then (user) =>
      if user?
        Promise.all([@state.favoritesPromise, @state.favoritedPromise])
          .then ([favorites, favorited])=>
            if not favorites?
              @createFavorites(user)
            else if favorited
              @removeSubjectFrom(favorites)
            else
              @addSubjectTo(favorites)
      else
        @promptToSignIn()

  render: ->
    <PromiseRenderer promise={@state.favoritedPromise}>{(favorited) =>
      <button
        className="favorites-button"
        type="button"
        onClick={@toggleFavorite}>
        <i className="
          fa fa-heart#{if @state.favorited then '' else '-o'}
          #{if @state.favorited then 'favorited' else ''}
        " />
      </button>
    }</PromiseRenderer>
