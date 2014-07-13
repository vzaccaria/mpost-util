input boxes;
string defaultfont;
defaultfont="pplr8r";
beginfig(1);



boxjoin(a.s=b.n);
boxit.h(btex $x^2$ etex);
boxit.i(btex x etex);
boxit.j(btex x etex);
boxit.k(btex y etex);
boxit.l(btex y etex);
boxit.m(btex y etex);
pair n.c; n.c = h.c;

boxjoin(a.s=b.n);
boxit.ha(btex $x^2$ etex);
boxit.ia(btex x etex);
boxit.ja(btex x etex);
boxit.ka(btex y etex);
boxit.la(btex y etex);
boxit.ma(btex y etex);
pair na.c; na.c = ha.c;

boxjoin(a.e=b.w);
circleit.aa(btex u etex);
aa.e - aa.c = (5bp, 0);
aa.n - aa.c = (0, 5bp);
circleit.bb(btex u etex);
bb.e - bb.c = (5bp, 0);
bb.n - bb.c = (0, 5bp);
pair o.c; o.c = aa.c;
pair p.c;
p.c = origin;
p.c - 0 * 40*(1bp,0) = n.c;
p.c - 1 * 40*(1bp,0) = na.c;
p.c - 2 * 40*(1bp,0) = o.c;

drawboxed(h,i,j,k,l,m);
drawboxed(ha,ia,ja,ka,la,ma);
drawboxed(aa,bb);
drawarrow aa.c{down} .. {curl 0}k.c;
endfig;
end;
