express  = require "express"
app      = express()
server   = require('http').createServer(app)
io       = require('socket.io').listen(server)
spawn    = require('child_process').spawn
{ Tail } = require "tail"

io.configure () =>
  io.set "log level", 1

{ SessionSocket } = require "./lib/session"
{ Index }         = require "./routes/index"

class exports.App
  constructor: (@app) ->
    @app.configure ( ) =>
      @app.set "views", __dirname + "/views"
      @app.set "view engine", "ejs"
      @app.use express.bodyParser()
      @app.use express.methodOverride()
      @app.use express.cookieParser()

      @app.use @app.router
      @app.use express.static(__dirname + "/public")

    index = new Index()

    @app.get  "/", index.render

app = new exports.App(app)
server.listen 8080

main_socket = null

filename = process.argv[2]
tail     = spawn "tail", ["-f", filename]

tail.stdout.on 'data', (data) ->
  io.sockets.emit 'log', data.toString('utf8')
