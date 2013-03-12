winston = require "winston"
winston.add(winston.transports.File, { filename: 'sample.log' })
winston.log "info", "Hello World", {complex: [1,4,6], "obj":"My Thing"}

messages = [
    {level: "info", message: "User Data logged with ID", data: {}},
    {level: "warn", message: "", data: {name: {first:"stu",last:"doe"}, ids:[1,2,4,7], email:"stu@doe.com"}},
    {level: "warn", message: "This is a test warning message flying by", data: {}},
    {level: "debug", message: "SELECT * FROM passwords_table WHERE security=0", data: {}},
    {level: "error", message: "A piece of code went wrong we need a massive multi-line stack trace", data: {status:404, error:"Page could not be found"}}
]


logger= () ->
  wait = Math.floor(Math.random()*700)
  message = messages[Math.floor(Math.random()*5)]
  setTimeout () ->
     winston.log message.level, message.message, message.data
     logger()
  , wait

logger()
