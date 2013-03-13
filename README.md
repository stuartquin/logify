# Logify

Web based log viewer

* Format JSON and SQL output
* Remote Log viewer
* Simple 'grep' like filters

![GitHub Logo](https://raw.github.com/stuartquin/logify/master/public/screenshots/screen.png)

## Why?

Allow other team members to view the logs of your locally running dev
environment.

## Installation

`npm install .`

## Usage

`coffee app.coffee --file "/path/to/log/file"`

The default port is 8080

## Input Mappers

Custom input handlers allow logify to support almost any log file format.
Handlers are simple coffeescript classes that intercept log data, manipulate 
and return in a format better suited to logify.

[examples](https://github.com/stuartquin/logify/tree/master/handlers)

You can specify a handler by it's file name:

`coffee app.coffee --file "/path/to/log/file" --handler winston`

This will parse all incoming loglines as 
[winston](https://github.com/flatiron/winston) format and output in logify
format.

