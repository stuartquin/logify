express  = require "express"
app      = express()
server   = require('http').createServer(app)
spawn    = require('child_process').spawn
{Tail}   = require "tail"
{ArgumentParser} = require "argparse"
{SessionSocket}  = require "./lib/session"
{Index}          = require "./routes/index"

parser = new ArgumentParser({
    version: "0.1",
    addHelp: true,
    description: "Web based log viewer"
})
parser.addArgument(
    ["-f", "--file"],
    {
        help: "File to be tailed",
        required: true
    }
)

parser.addArgument(
    ["-H", "--handler"],
    {
        help: "Specify a log format handler",
        defaultValue: "logfile"
    }
)

parser.addArgument(
    ["-p", "--port"],
    {
        help: "Port number for service",
        defaultValue: 8080
    }
)
args = parser.parseArgs()

io       = require('socket.io').listen(server)
io.configure () =>
  io.set "log level", 1

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

{Handler} = require "./handlers/#{args.handler}"
handler = new Handler()

main_socket = null
filename = args.file
tail     = spawn "tail", ["-f", filename]

tail.stdout.on 'data', (data) ->
  io.sockets.emit 'log', handler.parse data.toString('utf8')

port = args.port
app = new exports.App(app)
server.listen port

console.log "Listening to #{filename} on #{port}"
