input boxes;
string defaultfont;
defaultfont="pplr8r";
beginfig(1);

% declaration of spaced 

% declaration of spaced 

% declaration of spaced 
boxit.s0();
s0.e - s0.w = (20,0);
s0.n - s0.s = (0, 20);
boxit.e0(btex a etex);
e0.e - e0.w = (50,0);
e0.n - e0.s = (0, 50);
circleit.c0(btex b etex);
c0.e - c0.w = (50,0);
c0.n - c0.s = (0, 50);
% end of declaration of spaced 


% declaration of spaced 
boxit.e1(btex c etex);
e1.e - e1.w = (50,0);
e1.n - e1.s = (0, 50);
boxit.e2(btex d etex);
e2.e - e2.w = (50,0);
e2.n - e2.s = (0, 50);
boxit.e3(btex e etex);
e3.e - e3.w = (50,0);
e3.n - e3.s = (0, 50);
% end of declaration of spaced 
e0.nw - s0.nw = (100, 0);
(xpart(c0.w), ypart(c0.n)) - e0.nw = (100, 0);
e2.nw - e1.nw = (100, 0);
e3.nw - e2.nw = (100, 0);
% end of declaration of spaced 
e1.nw - s0.nw = (0, -1*100);
% end of declaration of spaced 
 
drawunboxed(s0);
drawboxed(e0);
drawboxed(c0);
drawboxed(e1);
drawboxed(e2);
drawboxed(e3);

path toState;
toState = e2.e{right} .. c0.w{right};
drawarrow toState;
label.top(btex to state etex, point .5length(toState) of toState + (5,0));
endfig;
end;
