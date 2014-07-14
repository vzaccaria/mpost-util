input boxes;
string defaultfont;
defaultfont="pplr8r";
beginfig(1);

% declaration of spaced 

% declaration of spaced 
boxit.e0(btex a etex);
e0.e - e0.w = (20,0);
e0.n - e0.s = (0, 20);


% declaration of joined boxes:

boxjoin(a.se=b.sw; a.ne=b.nw);
boxit.e1(btex b etex);
e1.e - e1.w = (20,0);
e1.n - e1.s = (0, 20);;
boxit.e2(btex b etex);
e2.e - e2.w = (20,0);
e2.n - e2.s = (0, 20);;
boxit.e3(btex b etex);
e3.e - e3.w = (20,0);
e3.n - e3.s = (0, 20);
boxjoin();
% end of declaration of joined boxes



% declaration of spaced 
boxit.e4(btex c etex);
e4.e - e4.w = (20,0);
e4.n - e4.s = (0, 20);
boxit.e5(btex d etex);
e5.e - e5.w = (20,0);
e5.n - e5.s = (0, 20);
boxit.e6(btex a etex);
e6.e - e6.w = (20,0);
e6.n - e6.s = (0, 20);


% declaration of joined boxes:

boxjoin(a.se=b.sw; a.ne=b.nw);
boxit.e7(btex b etex);
e7.e - e7.w = (20,0);
e7.n - e7.s = (0, 20);;
boxit.e8(btex b etex);
e8.e - e8.w = (20,0);
e8.n - e8.s = (0, 20);;
boxit.e9(btex b etex);
e9.e - e9.w = (20,0);
e9.n - e9.s = (0, 20);
boxjoin();
% end of declaration of joined boxes



% declaration of spaced 
boxit.e10(btex c etex);
e10.e - e10.w = (20,0);
e10.n - e10.s = (0, 20);
boxit.e11(btex d etex);
e11.e - e11.w = (20,0);
e11.n - e11.s = (0, 20);
% end of declaration of spaced 
e11.nw - e10.nw = (0, -1*20);
% end of declaration of spaced 
e5.nw - e4.nw = (0, -1*20);
e6.nw - e5.nw = (0, -1*20);
e7.nw - e6.nw = (0, -1*20);
e10.nw - e7.nw = (0, -1*20);
% end of declaration of spaced 
e1.nw - e0.nw = (40, 0);
e4.nw - e1.nw = (40, 0);
% end of declaration of spaced 
 
drawboxed(e0);
drawboxed(e1);
drawboxed(e2);
drawboxed(e3);
drawboxed(e4);
drawboxed(e5);
drawboxed(e6);
drawboxed(e7);
drawboxed(e8);
drawboxed(e9);
drawboxed(e10);
drawboxed(e11);
endfig;
end;
