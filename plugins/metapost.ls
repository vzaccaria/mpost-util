#!/usr/bin/env lsc
# options are accessed as argv.option

_               = require('underscore')
_.str           = require('underscore.string');
moment          = require 'moment'
fs              = require 'fs'
color           = require('ansi-color').set
{ spawn, kill } = require('child_process')
__q             = require('q')
sh              = require('shelljs')
os              = require('os')
shelljs         = sh
winston         = require('winston')
debug = require('debug')('metapost')

_.mixin(_.str.exports());
_.str.include('Underscore.string', 'string');

# How it is:
# beginfig(1);
# secondarydef v projectedalong w =
# if pair(v) and pair(w):
# (v dotprod w) / (w dotprod w) * w
# else:
# errmessage "arguments must be vectors"
# fi
# enddef;
# pair u[]; u1 = (20,80); u2 = (60,15);
# drawarrow origin--u1;
# drawarrow origin--u2;
# drawarrow origin--2*u2;
# u3 = u1 projectedalong u2;
# u4 = 2*u2 projectedalong u1;
# drawarrow origin--u3 withcolor blue;
# draw u1--u3 ;
# draw ((1,0)--(1,1)--(0,1))
# zscaled (6pt*unitvector(u2)) shifted u3;
# drawarrow origin--u4 withcolor blue;
# draw 2*u2--u4 ;
# draw ((1,0)--(1,1)--(0,1))
# zscaled (6pt*unitvector(-u1)) shifted u4;
# labeloffset := 4pt;
# label.rt(btex $u_1$ etex, u1);
# label.bot(btex $u_2$ etex, u2);
# label.bot(btex $2u_2$ etex, 2*u2);
# label.bot(btex $u_3$ etex, u3);
# label.lft(btex $u_4$ etex, u4);
# endfig;
# end;

tex    = (text) ->
  return -> 
    result: ("btex " + text + " etex"), name: []

just = (text) ->
  return ->
    result: (text), name: []

# math = ->
#   arg = it
#   return -> 
#     result: ("btex" + arg + "etex"), name: []

parse = (r, args) ->
    o        = get-options(args)
    nm       = get-name(args)
    nodes    = _.reduce r, ((a,c) -> a = a ++ c.nodes), []
    finalize = _.reduce r, ((a,c) -> a = a ++ c.finalize), []
    roots    = (r.map (.root))
    node-def = (r.map (.node-def)) * ""

    nm      ?= "undefined"
    return { opts: o, name: nm, nodes: nodes, node-def: node-def, roots: roots, finalize: finalize }

parse1 = (args) ->
    r = get-results(get-fst-array(args))
    parse(r, args)


parse0 = (args) ->
    r        = get-results(args)
    parse(r, args)


seq = (args) ->
    -> _.pick parse0(args), 'nodeDef', 'nodes', 'finalize'


get-name = (args) ->
        for a in args 
            if _.is-string(a)
              return a
        return undefined 

get-results = (args) ->
        res = []
        for a in args
          if _.is-function(a)
                res.push(a())
        return res

get-fst-array = (args) ->
        for a in args 
          if _.is-array(a)
            return a
        return []

get-options = (args) ->
        o = {}
        for a in args 
          if not _.is-function(a) and not _.is-string(a)
              o = _.extend(o, a)
        return o

box    = ->
    args = &[0 to ] 
    return -> 
        name = get-name args
        o    = get-options args
        res  = "boxit"
        res  = res + ".#name" if name?
        res  = res + "(" + (get-results(args).map (.result)) * "" + ");"
        res = res + line "#name.dx = #{o.dx};" if o?.dx?
        res = res + line "#name.dy = #{o.dy};" if o?.dy?
        return { node-def: line(res), nodes: [name], root: "#{name}.c" }

symtable = {}

circle    = ->
    args = &[0 to ] 
    return -> 
        name  = get-name args
        o     = get-options args
        o.dx ?= "5bp"
        o.dy ?= "5bp"
        res   = "circleit"
        res   = res + ".#name" if name?
        res   = res + "(" + (get-results(args).map (.result)) * "" + ");"
        res = res + line "#name.e - #name.c = (#{o.dx}, 0);" if o?.dx?
        res = res + line "#name.n - #name.c = (0, #{o.dy});" if o?.dy?
        # res = res + line "#name.c = (#{o.cx}, #{o.cy})" if o.cx? and o.cy?
        return { node-def: line(res), nodes: [name], root: "#{name}.c" }




join = ->
    args = &[0 to ]
    return -> 
        { opts, name, nodes, node-def, roots } = parse1(args)
        res = line "boxjoin(a.e=b.w);" if not opts?.vertical?
        res = line "boxjoin(a.s=b.n);" if opts?.vertical?
        res = res + node-def
        res = res + line "pair #{name}.c; #name.c = #{roots[0]};"
        finalize = line "drawboxed(#{nodes * ','});"
        return { node-def: line(res), nodes: nodes, root: "#{name}.c", finalize: finalize }

draw-arrow = ->
    args = &[0 to ]
    return -> 
        r = get-results(args)
        o = get-options(args)
        res = ""
        res = res + line "drawarrow #{r[0].result}.c{down} .. {curl 0}#{r[1].result}.c;" if o.south?
        res = res + line "drawarrow #{r[0].result}.c{down} .. {curl 0}#{r[1].result}.c;" if not o.south?
        return { nodes: [], finalize: res }

array = ->
    args = &[0 to ]
    return -> 
        { opts, name, nodes, node-def, roots, finalize } = parse1(args)
        opts.space ?= "1"
        opts.dist ?= "#{opts.space}*(0,1bp)" if opts.vertical?
        opts.dist ?= "#{opts.space}*(1bp,0)" if not opts.vertical
        res = ""
        res = res + node-def
        res = res + line "pair #{name}.c;"
        if opts.root-at?
          res = res + line "#{name}.c = #{opts.root-at};"
        for i,v of roots
          res = res + line "#{name}.c - #i * #{opts.dist} = #v;"
        return { node-def: line(res), nodes: nodes, root: "#{name}.c", finalize: finalize}



# displace = (opts)

diagram = (codebody) ->
  { node-def, nodes, finalize } = codebody()
  return """
  input boxes;
  string defaultfont;
  defaultfont="pplr8r";
  beginfig(1);
  #node-def
  #{finalize * ''}
  endfig;
  end;"""

line = -> "\n#it"
# rbox   = through # round box
# circle = through

# dot = circle empty, bg-color: black, dx: .75

# row = (array, space) ->
#         [ e() for e in array ] * '\n'

# col = (array, space) ->
#         [ e() for e in array ] * '\n'

   #  matrix ->
   #      row [
   #          empty
   #          circle 'A', ->
   #              stack [
   #                  -> C 
   #                  -> "b^*" 
   #              ]
   #          circle 'B' ->
   #              circle ->
   #                  tex "stop"
   #      ]
   # draw "..", up "A", down "B"

d = diagram seq [
                  array([

                    join([
                        box 'h' , (tex "$x^2$")
                        box 'i' , (tex "x")
                        box 'j' , (tex "x")
                        box 'k' , (tex "y")
                        box 'l' , (tex "y")
                        box 'm' , (tex "y")
                        ], 'n', { +vertical })

                    join([
                        box 'ha' , (tex "$x^2$")
                        box 'ia' , (tex "x")
                        box 'ja' , (tex "x")
                        box 'ka' , (tex "y")
                        box 'la' , (tex "y")
                        box 'ma' , (tex "y")
                        ], 'na', { +vertical })

                    join [
                      circle 'aa', (tex "u")
                      circle 'bb', (tex "u")
                      ], 'o', 
                      
                    ], 'p', {space: "40", root-at: 'origin'})

                  draw-arrow (just 'aa'), (just 'k')
                  ]


console.log d

# _module = ->

#     diagram = (codebody) ->
#         return "beginfig(1); \n #{codebody()}; \nendfig; \nend;"


          
#     iface = { 
#         diagram: diagram
#     }
  
#     return iface
 
# module.exports = _module()