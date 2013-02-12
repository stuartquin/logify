{ Tail } = require "tail"


class exports.SessionSocket
  constructor: (@project_id, @socket, @io)->
    @join @socket

  join: (socket) ->
    @bind_events socket

  tail_file: () ->
    console.log Tail

  # Loads all existing session data and emits
  load_session: ()->
    query =
      project_id: @project_id

    Highlight.find query, (error, results) =>
      @socket.emit "load_session", results

  # Sends a message to all subscribers except the broadcaster
  broadcast: (update_type, data, broadcast_id) ->
    @io.sockets.in(@project_id).emit update_type, data

  store_event: (data) ->
    query =
      project_id: @project_id
      id:         data.id

    delete data._id
    # We don't want to overwrite comments
    delete data.comments
    data.deleted    = false
    data.project_id = @project_id

    Highlight.update query, data, upsert: true,(err) ->
      return

  add_comment: (data) ->
    query =
      project_id: @project_id
      id:         data.highlight_id

    update =
      $push:
        comments: data

    Highlight.update query, update, upsert: true,() =>
        return

    @store_user_comment data

  # Store the highlight ID of the last comment a user added
  store_user_comment: (comment) ->
    Project.update
      _id:        @project_id
      "users._id": comment.created_by
    ,
      $set:
        "users.$.last_commented": comment.highlight_id
    ,
      upsert: true
    , (err) ->
      console.log err
      return

  delete_highlight: (data) ->
    query =
      project_id: @project_id
      id:         data.id

    update =
      deleted: true

    Highlight.update query, update,() =>
        return

  bind_events: (socket) ->
    socket.on "highlight_update", (data) =>
      @store_event data
      @broadcast "highlight_redraw", data, socket.id

    socket.on "new_comment", (data) =>
      @add_comment data
      @broadcast "append_comment", data, socket.id

    socket.on "highlight_delete", (data) =>
      @delete_highlight data
      @broadcast "highlight_remove", data, socket.id
