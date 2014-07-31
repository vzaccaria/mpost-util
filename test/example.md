This is an example diagram

in a markdown *context*

<script metapost>

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

return diagram test-diag-s(100)
</script>

This is an example diagram

in a markdown *context*
