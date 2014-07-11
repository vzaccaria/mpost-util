
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

seq = (args) ->
    ->
        { result: ((get-results(args).map (.result)) * ""), name: [] }


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
        res = res + line "#name.dx = #{o.dx};" if o.dx?
        res = res + line "#name.dy = #{o.dy};" if o.dy?
        return { result: line(res), name: name }

circle    = ->
    args = &[0 to ] 
    return -> 
        name  = get-name args
        o     = get-options args
        res   = "circleit"
        res   = res + ".#name" if name?
        res   = res + "(" + (get-results(args).map (.result)) * "" + ");"
        res = res + line "#name.e - #name.c = (5bp, 0);"
        res = res + line "#name.n - #name.c = (0, 5bp);"
        # res = res + line "#name.c = (#{o.cx}, #{o.cy})" if o.cx? and o.cy?
        return { result: line(res), name: name }

join = ->
    args = &[0 to ]
    return -> 
        r       = get-results(get-fst-array(args))
        o       = get-options(args)
        names   = r.map (.name)
        results = (r.map (.result)) * ""
        res     = ""
        res     = res + line "boxjoin(a.e=b.w);" if not o.vertical?
        res     = res + line "boxjoin(a.s=b.n);" if o.vertical?        
        res     = res + results if results?
        res     = res + line("drawboxed(" + (names * ',') + ");") if names?
        return { result: line(res), name: [] }

draw-arrow = ->
    args = &[0 to ]
    return -> 
        r = get-results(args)
        o = get-options(args)
        res = ""
        res = res + line "drawarrow #{r[0].result}.c{down} .. .{curl0}#{r[1].result}.c;" if o.south?
        res = res + line "drawarrow #{r[0].result}.c{down} .. .{curl0}#{r[1].result}.c;" if not o.south?
        return { result: line(res), name: [] }


diagram = (codebody) ->
  return """
  input boxes;
  beginfig(1);
  #{codebody().result}
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

              join([
                  box 'h' , (tex "$x^2$")
                  box 'i' , (tex "x")
                  box 'c' , (tex "x")
                  box 'd' , (tex "y")
                  box 'e' , (tex "y")
                  box 'f' , (tex "y")
                  ]       , { +vertical })

              join [
                circle 'aa', (tex "u")
                circle 'bb', (tex "u")
                ]

              draw-arrow (just 'h'), (just 'f')

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