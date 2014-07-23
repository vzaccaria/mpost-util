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
debug           = require('debug')('metapost')
Table           = require("cli-table")

table = -> 
  hd = _.keys(it[0])
  tt = (new Table(head: hd))
  for e in it 
    tt.push(_.values(e))
  return tt.toString()

_.mixin(_.str.exports());
_.str.include('Underscore.string', 'string');


tex    = (text) ->
  ("btex " + text + " etex")

just = (text) ->
  return ->
    result: (text), name: []


unit = "mm"

class circle-element
  @num = 0
  @dx = 20
  @dy = 20
  ~>
    @name = "c" + @@num
    @@num = @@num + 1
    @root = "(xpart(#{@name}.w), ypart(#{@name}.n))"
    @text = ""
    @dx = @@dx 
    @dy = @@dy 


  declare: ~>
    r = "circleit.#{@name}(#{@text});"
    r = r + line "#{@name}.e - #{@name}.w = (#{@dx},0);" if @dx?
    r = r + line "#{@name}.n - #{@name}.s = (0, #{@dy});" if @dy?
    return r

  finalize: ~>
    "drawboxed(#{@name});"

class empty-element
  @num = 0
  ~>
    @name = "s" + @@num
    @@num = @@num + 1
    @root = "#{@name}.nw"
    @text = ""
    @dx = 20 
    @dy = 20 

  declare: ~>
    r = "boxit.#{@name}();"
    r = r + line "#{@name}.e - #{@name}.w = (#{@dx},0);" if @dx?
    r = r + line "#{@name}.n - #{@name}.s = (0, #{@dy});" if @dy?
    return r

  finalize: ~>
    "drawunboxed(#{@name});"

class box-element 
  @num = 0
  @dx = 20
  @dy = 20
  ~>
    @name = "e" + @@num
    @@num = @@num + 1
    @root = "#{@name}.nw"
    @text = ""
    @dx = @@dx 
    @dy = @@dy 

  declare: ~>
    r = "boxit.#{@name}(#{@text});"
    r = r + line "#{@name}.e - #{@name}.w = (#{@dx},0);" if @dx?
    r = r + line "#{@name}.n - #{@name}.s = (0, #{@dy});" if @dy?
    return r

  finalize: ~>
    "drawboxed(#{@name});"

circle = ->
    block = it 
    box-data = new circle-element()
    block.apply(box-data)
    return box-data

box = ->
    block = it 
    box-data = new box-element()
    block.apply(box-data)
    return box-data

empty = ->
    block = it 
    box-data = new empty-element()
    block.apply(box-data)
    return box-data

class joined-elements
  @num = 0
  @arrows = {}
  @declare-arrows = ~>
    res = ""
    for k, v of @arrows 
      if v.src? and v.dst?
        path  = "#{v.src} .. #{v.dst}"
        res   = res + line "path #k;"
        res   = res + line "#k = #path;"
        res   = res + line "drawarrow #k;"
        point = "point .5length(#k) of #k + (5,0)"
        res   = res + line "label.top(#{tex v.name}, #point);"
    return res 

  ~>
    @name     = "j" + @@num
    @@num     = @@num + 1
    @elements = []
    @vertical = false
    @root     = @name

  box: ~>
    nb = box(it)
    if @elements.length == 0
      @root = nb.root
    @elements.push(nb)
    return nb.name

  empty: ~>
    nb = empty(->)
    @root = nb.root if @elements.length == 0
    @elements.push(nb)
    return nb.name

  circle: ~>
    nb = circle(it)
    @root = nb.root if @elements.length == 0
    @elements.push(nb)
    return nb.name

  out: (v, arrowname, node) ~~>
    ex = 
      | v == \up    => "#node.n{up}"
      | v == \down  => "#node.s{down}"
      | v == \left  => "#node.w{left}"
      | v == \right => "#node.e{right}"
    an = _.camelize(_.slugify(arrowname))
    @@arrows[an] ?= {}
    @@arrows[an].src = ex
    @@arrows[an].name = arrowname
    return node

  in: (v, arrowname, node) ~~>
    ex = 
      | v == \up   => "#node.n{down}"
      | v == \down => "#node.s{up}"
      | v == \left => "#node.w{right}"
      | v == \right => "#node.e{left}"
    an = _.camelize(_.slugify(arrowname))
    @@arrows[an] ?= {}
    @@arrows[an].dst = ex
    return node

  declare: ~>
    res = "\n\n% declaration of joined boxes:\n"
    res = res + line "boxjoin(a.se=b.sw; a.ne=b.nw);" if not @vertical? or @vertical == false
    res = res + line "boxjoin(a.sw=b.nw; a.se=b.ne);" if @vertical? and @vertical==true
    res = res + line ((@elements.map (-> it.declare())) * ";\n")
    res = res + line "boxjoin();"
    res = res + "\n% end of declaration of joined boxes\n\n"


  finalize: ~>
    (@elements.map (-> it.finalize())) * "\n"


join = ->
    block = it
    jj = new joined-elements() 
    block.apply(jj)
    return jj

space = ->
    block = it 
    nn = new elements()
    block.apply(nn)
    return nn

class elements extends joined-elements
  @num = 0
  ~>
    @name = "es"+@@num
    @@num = @@num + 1
    @elements = []
    @constraints = []

  joined: (block) ~>
    nb = join(block)
    debug "Adding #{nb.name} to #{@name}"
    @root = nb.root if @elements.length == 0
    @elements.push(nb)

  row: (num =1, block) ~>
    @add-spaced(block, "(#num, 0)")

  column: (num =1, block) ~>
    @add-spaced(block, "(0, -1*#num)")

  add-spaced: (block, nn) ~>
    el = space(block)
    @root = el.root if @elements.length == 0
    debug "Adding #{el.name} to #{@name}"

    i = 0
    prev = el.elements[i]
    next = el.elements[i+1]
    while(next?)
      @constraints.push({prev: prev, next: next, delta: nn})
      i = i + 1
      prev = el.elements[i]
      next = el.elements[i+1]

    @elements.push(el)


  declare: ~>
    d = "\n% declaration of spaced \n"
    d = d + (@elements.map (-> it.declare())) * "\n"
    d = d + (@constraints.map (-> "#{it.next.root} - #{it.prev.root} = #{it.delta};")) * "\n"
    d = d + "\n% end of declaration of spaced \n"
    return d 


  finalize: ~>
    return (@elements.map (-> it.finalize())) * "\n"

diagram = ->
  block = it
  jj = new elements() 
  block.apply(jj)
  debug JSON.stringify(jj.elements, 0, 4)
  return """
  input boxes;
  string defaultfont;
  defaultfont="pplr8r";
  beginfig(1);
  #{jj.declare()} 
  #{jj.finalize()}
  #{joined-elements.declare-arrows()}
  endfig;
  end;"""

line = -> "\n#it"

test-diag-s = (s) ->
  -> 
    box-element.dx = s/2
    box-element.dy = s/2 
    circle-element.dx = s/2
    circle-element.dy = s/2 
    @column s, ->
      @row s, ->
        @empty ()
        @box    (-> @text = tex \a) 
        @circle (-> @text = tex \b) |> @in  'left', 'to state'
      @row s, ->
        @box    (-> @text = tex \c)
        @box    (-> @text = tex \d) |> @out  'right', 'to state'
        @box    (-> @text = tex \e) 

test-diag = diagram test-diag-s(100)

    

_module = ->

    iface = { 
        diagram: diagram
        test-diag: test-diag
        box-element: box-element
        circle-element: circle-element 
        empty-element: empty-element
        tex: tex
    }
  
    return iface
 
module.exports = _module()