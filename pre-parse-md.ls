#!/usr/bin/env lsc
# options are accessed as argv.option

_       = require('underscore')
_.str   = require('underscore.string');
moment  = require 'moment'
fs      = require 'fs'
color   = require('ansi-color').set
os      = require('os')
shelljs = require('shelljs')
table   = require('ansi-color-table')
ls = require('LiveScript')

_.mixin(_.str.exports());
_.str.include('Underscore.string', 'string');

name        = "pre-parse-md.ls"
description = "converts custom script tags in markdown by external plugins. Generates markdown in output."
author      = "Vittorio Zaccaria"
year        = "2014"

info = (s) ->
  console.log color('inf', 'bold')+": #s"

err = (s) ->
  console.log color('err', 'red')+": #s"

warn = (s) ->
  console.log color('wrn', 'yellow')+": #s"

src = __dirname
otm = if (os.tmpdir?) then os.tmpdir() else "/var/tmp"
cwd = process.cwd()

setup-temporary-directory = ->
    name = "tmp_#{moment().format('HHmmss')}_tmp"
    dire = "#{otm}/#{name}" 
    shelljs.mkdir '-p', dire
    return dire

remove-temporary-directory = (dir) ->
    shelljs.rm '-rf', dir 
    
usage-string = """

#{color(name, \bold)}. #{description}
(c) #author, #year

Usage: #{name} [--option=V | -o V] file.md
"""

require! 'optimist'

argv     = optimist.usage(usage-string,
              pdf:
                alias: 'p', description: 'Target a markdown backend that needs local pdf files', boolean: true

              help:
                alias: 'h', description: 'this help', default: false

                         ).boolean(\h).argv

file = (argv._)[0]

if(argv.help || not file?)
  optimist.showHelp()
  return

f = shelljs.cat(file)

metapost-regex = /<script metapost>(.|\n)*<\/script>/gi

parse-metapost = (code) ->
  code = code.replace('<script metapost>', '').replace('<\/script>','')
  ls.run ('return "just livescript"')

f = f.replace metapost-regex, parse-metapost

console.log f



