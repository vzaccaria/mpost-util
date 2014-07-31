#!/usr/bin/env lsc

{ parse-args, setup, bindir, graceful-exit, escape } = require('cli-lib')
{ to-temp, from-temp, in-temporary-directory, run } = require('cli-lib')
{ cfx } = require('cli-lib')

require! 'shelljs'
ls = require('LiveScript')

debug = require('debug')('it.zaccaria.mp-convert-to-md')
path = require('path')

setup ->
  @name = "mp-convert-to-md"
  @filename = __filename 

argv = parse-args ->
  @b "svg", "s", false, "use local svg files"
  @b "png", "g", true, "use local png files"
  @b "pdf", "p", false, "use local pdf files"
  @b "dbox", "x", false, "use dropbox"
  @s "dboxurl", "u", 'https://dl.dropboxusercontent.com/u/5867765/images', "Dropbox url"

filename = (argv._)[0]
ex = path.extname(filename)

if(not filename? || not ex==".md")
  console.log "Please specify a .md file"
  return

fignum = 0
files = []

if argv.dbox
  argv.dir = "/Users/zaccaria/Dropbox/Public/images"
else 
  argv.dir = "./figures"

sfx = ->
      | argv.pdf  => ".pdf"
      | argv.svg  => ".svg"
      | otherwise => ".png"

get-figname = ->
  local-source = filename |> cfx ".md" "-#fignum.mp"
  console.log "Generating #local-source"
  suffix       = local-source  |> cfx ".mp" "#{sfx()}"
  local-file   = "#{argv.dir}/#suffix"
  remote-file  = "#{argv.dboxurl}/#suffix"
  fignum := fignum + 1
  return { remote-file: remote-file, local-file: local-file, local-source: local-source }

parse-metapost = (code) ->
  code = code.replace('<script metapost>', '').replace('<\/script>','')
  code = "{ diagram, box-element, circle-element, empty-element, tex } = require('mpost-util/plugins/metapost');\n" + code
  { remote-file, local-file, local-source } = get-figname()
  mp = ls.run(code)
  mp.to(argv.dir + "/" + local-source)
  files.push(local-source)
  if argv.dbox
    return "![](#{remote-file})"
  else 
    return "![](#{local-file})"

## Main 

shelljs.mkdir('-p', argv.dir)

f = shelljs.cat(filename)
metapost-regex = /<script metapost>(.|\n)*<\/script>/gi
f = f.replace metapost-regex, parse-metapost
f.to(filename |> cfx ".md" "-tex.md")

options = 
  | argv.pdf => ""
  | argv.svg => " -s "
  | otherwise => " -g "

for f in files 
  escapedDir = escape(argv.dir)
  escapedFile = escape(f)
  bindir().then ->
    bn = it
    cmd = "cd #escapedDir && #bn/mp-gen-pdf-figures -v #options #escapedFile"
    run cmd 
  .done()





