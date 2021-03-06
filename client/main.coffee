class Filters
  constructor: () ->
    @active_filter = ""
    @json_enabled  = true
    @sql_enabled   = true

    field = $("#filter_field")
    field.keypress (evt) =>
      if evt.charCode == 13
        @active_filter = field.val()

    $("#sql_toggle").button "toggle"
    $("#json_toggle").button "toggle"

    $("#sql_toggle").click (e) =>
      e.stopImmediatePropagation()
      $("#sql_toggle").toggleClass "active"
      @sql_enabled = !@sql_enabled
    
    $("#json_toggle").click (e) =>
      e.stopImmediatePropagation()
      $("#json_toggle").toggleClass "active"
      @json_enabled = !@json_enabled


class LogLine

  # Maps from codes to bootstrap label classes
  @label_map =
    error: "important"
    debug: "info"
    warn: "warning"

  constructor: (@line, @filters)->
    @active_filter = @filters.active_filter
    @format_json = @filters.json_enabled
    @format_sql  = @filters.sql_enabled
    @line_class  = ""

  highlight_type: () =>
    @line = @line.replace  /(DEBUG|WARNING|WARN|INFO|ERROR)/i, ( match, group1 ) ->
      label = group1.toLowerCase()
      label = LogLine.label_map[label] or label
      return "<strong class='label label-"+label+"'>"+match+"</strong>"

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

    @line = @line.replace /\\n/gi, "<br />"
    @line = @line.replace /\\t/gi, "  "

  highlight_filter: () =>
    if @active_filter == ""
      return

    if @line.match @active_filter
      @line = @line.replace new RegExp(@active_filter, "gi"), (match) ->
        return "<strong class='text-success'>"+match+"</strong>"
      @line_class = "filtered"
    else
      @line_class = "muted-line"

  render: (index, callback) ->
    @highlight_type()
    @highlight_http_code()
    @highlight_filter()

    if @format_json
      @highlight_json()

    if @format_sql
      @highlight_sql()

    if index % 2 != 0
      @line_class += " striped"

    output  = $("<div class='line #{@line_class}'>")
    output.html @line
    callback output

class LogPanel
  # Maps from codes to bootstrap label classes
  @label_map =
    error: "important"
    debug: "info"

  constructor: (@id, @filters)->
    @panel_el = $(@id)
    @line_count = 0
    @max_lines  = 1000

  add_line: (data) ->
    logLine = new LogLine(data, @filters)

    logLine.render @line_count, (formatted) =>
      @panel_el.prepend formatted
      formatted.find("pre code").each (i, e) ->
        hljs.highlightBlock e

      @line_count++
      if @line_count > @max_lines
        @panel_el.find("div:last-child").remove()

  clear: () ->
    @line_count = 0
    @panel_el.html("")


$( document ).ready ()->
  socket = io.connect()

  filters     = new Filters()
  all_lines   = new LogPanel("#log_output", filters)
  logs_paused = false

  $("#clear_logs").click () =>
    all_lines.clear()
  
  $("#pause_logs").click () =>
    $("#pause_logs").find("i").toggleClass("icon-pause").toggleClass "icon-play"
    $("#pause_logs").toggleClass("btn-success")
    logs_paused = !logs_paused

  socket.on "log", (data) ->
    if !logs_paused
      all_lines.add_line data
