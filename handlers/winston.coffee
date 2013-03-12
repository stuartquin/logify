# Parser for winston log format
_ = require "underscore"

class exports.Handler
  parse: (data) ->
    rows = data.split "\n"
    log_str = ""
   
    for line in rows
      if line != ""
        log_obj = JSON.parse(line)
        log_str += "#{log_obj.timestamp}:#{log_obj.level} - #{log_obj.message}"
        delete log_obj.timestamp
        delete log_obj.level
        delete log_obj.message

        if not _.isEmpty log_obj
          log_str += JSON.stringify(log_obj)

        log_str += "<br />"
    return log_str
