#!/usr/bin/env lsc

{ parse-args, setup, bindir, graceful-exit, escape } = require('cli-lib')
{ to-temp, from-temp, in-temporary-directory, run } = require('cli-lib')
{ cfx } = require('cli-lib')

debug = require('debug')('it.zaccaria.mp-md2pdf')
path = require('path')

setup ->
  @name = "mp-md2pdf"
  @filename = __filename 

argv = parse-args ->
  @b "example", "e", false, "show an example"

file = (argv._)[0]
ex = path.extname(file)

debug "Received #file - Extension: #ex"

temporary-md  = file |> cfx '.md' '-tex.md'  |> escape
temporary-pdf = file |> cfx '.md' '-tex.pdf' |> escape
final-pdf     = file |> cfx '.md' '.pdf' |> escape
file          = file |> escape

bindir().then ->
  run "#{it}/mp-convert-to-md -v -p #file" 
  .then -> run "md2pdf.sh #temporary-md"
  .then -> run "mv #temporary-pdf #final-pdf"
  .then -> run "rm -rf ./figures"
  .then -> run "rm #temporary-md"

