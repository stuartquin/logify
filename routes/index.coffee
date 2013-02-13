http      = require "http"
crypto    = require "crypto"
fs        = require "fs"

class exports.Index

  render: ( req, res ) =>
    res.render "index",
      user_data:      false
      project_data:   false
    return
