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

Table = require("cli-table")

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

# init-num = -> 
#   return "A"

# get-next-num = (n) ->
#   String.fromCharCode(n.charCodeAt(my_string.length-1)+1) 

class box-element 
  @num = 0
  ~>
    @name = "e" + @@num
    @@num = @@num + 1
    @root = "#{@name}.nw"
    @text = ""
    @dx = 20 
    @dy = 20 

  declare: ~>
    r = "boxit.#{@name}(#{@text});"
    r = r + line "#{@name}.e - #{@name}.w = (#{@dx},0);" if @dx?
    r = r + line "#{@name}.n - #{@name}.s = (0, #{@dy});" if @dy?
    return r

  finalize: ~>
    "drawboxed(#{@name});"


box = ->
    block = it 
    box-data = new box-element()
    block.apply(box-data)
    return box-data

class joined-elements
  @num = 0
  ~>
    @name     = "j" + @@num
    @@num     = @@num + 1
    @elements = []
    @vertical = false
    @root     = @name

  add-box: ~>
    newbox = box(it)
    if @elements.length == 0
      @root = newbox.root
    @elements.push(newbox)

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

class elements  
  @num = 0
  ~>
    @name = "es"+@@num
    @@num = @@num + 1
    @elements = []
    @constraints = []

  add-joined-boxes: (block) ~>
    nb = join(block)
    debug "Adding #{nb.name} to #{@name}"
    @root = nb.root if @elements.length == 0
    @elements.push(nb)

  add-box: (block) ~>
    nb = box(block)
    debug "Adding #{nb.name} to #{@name}"
    @root = nb.root if @elements.length == 0
    @elements.push(nb)

  add-hspaced: (num =1, block) ~>
    @add-spaced(block, "(#num, 0)")

  add-vspaced: (num =1, block) ~>
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
  endfig;
  end;"""

line = -> "\n#it"

d = diagram ->
  # @add-box (-> @text = tex \c)

  @add-hspaced 40, ->
    @add-box (-> @text = tex \a)
    @add-joined-boxes ->
      @add-box (-> @text = tex \b)
      @add-box (-> @text = tex \b)
      @add-box (-> @text = tex \b)
    @add-vspaced 20, ->
      @add-box (-> @text = tex \c)
      @add-box (-> @text = tex \d)
      @add-box (-> @text = tex \a)
      @add-joined-boxes ->
        @add-box (-> @text = tex \b)
        @add-box (-> @text = tex \b)
        @add-box (-> @text = tex \b)
      @add-vspaced 20, ->
        @add-box (-> @text = tex \c)
        @add-box (-> @text = tex \d)

console.log d

# _module = ->

#     diagram = (codebody) ->
#         return "beginfig(1); \n #{codebody()}; \nendfig; \nend;"


          
#     iface = { 
#         diagram: diagram
#     }
  
#     return iface
 
# module.exports = _module()