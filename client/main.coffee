class Filters
  constructor: () ->
    @active_filter = ""
    field = $("#filter_field")
    field.keypress (evt) =>
      if evt.charCode == 13
        @active_filter = field.val()

    $("#clear_logs").click () ->
      $("#log_output").html("")
      line_count = 0

class LogLine
  constructor: (@line, @active_filter)->
    @format_json = true
    @line_class  = ""

  highlight_type: () =>
    @line = @line.replace  /(WARNING|INFO|ERROR)/i, ( match, group1 ) ->
      return "<span class='text-"+group1.toLowerCase()+"'>"+match+"</span>"

  highlight_http_code: () =>
    @line = @line.replace  /GET|POST|PUT|DELETE/, (match) ->
      return "<strong>"+match+"</strong>"

  highlight_json: () =>
    @line = @line.replace /({(?:.*):(?:.*)})/gi, (match) ->
      try
        converted = JSON.parse match
      catch error
        converted = match
        console.log error
        
      converted = JSON.stringify converted, undefined, 2
      return "<pre><code class='json'>#{converted}</code></pre>"

  highlight_sql: () =>
    @line = @line.replace /(SELECT .+ FROM .+(WHERE)?)/gi, (match) ->
      return "<pre><code class='sql'>#{match}</code></pre>"

  highlight_filter: () =>
    if @active_filter == ""
      return

    if @line.match @active_filter
      @line = @line.replace new RegExp(@active_filter, "gi"), (match) ->
        return "<strong class='text-success'>"+match+"</strong>"
      @line_class = "filtered"
    else
      @line_class = "muted"

  render: (callback) ->
    @highlight_type()
    @highlight_http_code()
    @highlight_filter()

    if @format_json
      @highlight_json()
      @highlight_sql()

    output  = $("<div class='line #{@line_class}'>")
    output.html @line
    callback output

line_count = 0
max_lines  = 1000

$( document ).ready ()->
  socket = io.connect()

  filters = new Filters()

  socket.on "log", (data) ->
    logLine = new LogLine(data, filters.active_filter)

    logLine.render (formatted) ->
      $( "#log_output" ).prepend formatted
      formatted.find("pre code").each (i, e) ->
        hljs.highlightBlock e

      line_count++
      if line_count > max_lines
        $( "#log_output div:last-child" ).remove()

