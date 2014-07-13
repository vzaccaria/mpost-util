input boxes;
string defaultfont;
defaultfont="pplr8r";
beginfig(1);



boxjoin(a.sw=b.nw; a.se=b.ne);
boxit.q(btex y etex);
boxit.r(btex y etex);
boxjoin();
boxit.h(btex $x^2$ etex);

boxjoin(a.se=b.sw; a.ne=b.nw);
boxit.i(btex x+3+1 etex);
boxit.j(btex x+5+1 etex);
boxjoin();
boxit.k(btex 3+1 etex);
boxit.l(btex y etex);
boxit.m(btex y etex);
pair p.c;
p.c = origin;
p.c - 0 * 40*(-1mm,0) = q.c;
p.c - 1 * 40*(-1mm,0) = h.c;
p.c - 2 * 40*(-1mm,0) = i.c;
p.c - 3 * 40*(-1mm,0) = k.c;
p.c - 4 * 40*(-1mm,0) = l.c;
p.c - 5 * 40*(-1mm,0) = m.c;

drawboxed(q,r);
drawboxed(h);
drawboxed(i,j);
drawboxed(k);
drawboxed(l);
drawboxed(m);
drawarrow h.c{down} .. {curl 0}j.c;
endfig;
end;
