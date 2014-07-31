#!/usr/bin/env lsc

{ parse-args, setup, bindir, graceful-exit, escape } = require('cli-lib')
{ to-temp, from-temp, in-temporary-directory, run } = require('cli-lib')
{ cfx } = require('cli-lib')
{ cat, mkdir } = require('shelljs')

debug = require('debug')('it.zaccaria.mp-gen-pdf-figures')
path = require('path')

setup ->
  @name = "mp-gen-pdf-figures"
  @filename = __filename 

argv = parse-args ->
  @b "svg", "s", false, "generates SVG figures"
  @b "png", "g", false, "generates PNG figures"

filename = (argv._)[0]
ex = path.extname(filename)

if(not filename? || not ex==".mp")
  console.log "Please, specify an .mp file"
  return


texname      = filename |> cfx '.mp' '.mp'
epsname      = filename |> cfx '.mp' '.1'
logname      = filename |> cfx '.mp' '.log'
mpxname      = filename |> cfx '.mp' '.mpx'
pdfname      = filename |> cfx '.mp' '.pdf'
svgname      = filename |> cfx '.mp' '-1.svg'
pngname      = filename |> cfx '.mp' '-1.png'
finalsvgname = filename |> cfx '.mp' ".svg"
finalpngname = filename |> cfx '.mp' ".png"
finalpdfname = filename |> cfx '.mp' ".pdf"

    

prologue = '''
verbatimtex
%&latex
\\documentclass[12pt]{article}
\\usepackage[latin1]{inputenc}
\\usepackage[T1]{fontenc}
\\begin{document}
etex
prologues:=3;
'''

mpost-file = cat(filename)
temporary = prologue + mpost-file

temporary.to(texname)

run "mpost #{escape texname}"
  .then -> run "epstopdf #{escape epsname}"
  .then -> run "rm #texname #epsname #logname #mpxname"
  .then -> 
    if argv.svg 
      return run "pdf2svg #pdfname #svgname"
                .then -> run "rm #pdfname"
                .then -> run "mv #svgname #finalsvgname "
    else 
        if argv.png 
            return run "pdftocairo -png #pdfname -transp -r 300"
                    .then -> run "rm #pdfname"
                    .then -> run "mv #pngname #finalpngname"
        else 
            return run "mv #pdfname #finalpdfname"            
  .fail ->
     console.log "Mpost failed. #it"








