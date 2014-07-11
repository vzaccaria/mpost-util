This is an example diagram

in a markdown *context*

<script metapost>

beginfig(1);
secondarydef v projectedalong w =
if pair(v) and pair(w):
(v dotprod w) / (w dotprod w) * w
else:
errmessage "arguments must be vectors"
fi
enddef;
pair u[]; u1 = (20,80); u2 = (60,15);
drawarrow origin--u1;
drawarrow origin--u2;
drawarrow origin--2*u2;
u3 = u1 projectedalong u2;
u4 = 2*u2 projectedalong u1;
drawarrow origin--u3 withcolor blue;
draw u1--u3 ;
draw ((1,0)--(1,1)--(0,1))
zscaled (6pt*unitvector(u2)) shifted u3;
drawarrow origin--u4 withcolor blue;
draw 2*u2--u4 ;
draw ((1,0)--(1,1)--(0,1))
zscaled (6pt*unitvector(-u1)) shifted u4;
labeloffset := 4pt;
label.rt(btex $u_1$ etex, u1);
label.bot(btex $u_2$ etex, u2);
label.bot(btex $2u_2$ etex, 2*u2);
label.bot(btex $u_3$ etex, u3);
label.lft(btex $u_4$ etex, u4);
endfig;
end;

</script>

This is an example diagram

in a markdown *context*
