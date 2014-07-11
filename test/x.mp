u:=10bp; % unit of length
input mpcirc;
beginfig(1);
prepare (L,R,C,Vac); % mention your elements
z0=(0,0); % lower left node
ht:=6u; % height of circuit
z1=z0+(0,ht); % upper left node
Vac=.5[z0,z1]; % location of voltage
Vac.t=T.u; % rotated 90 degrees
L.t=R.t=C.t=T.r; % default orientation
% set equal distances
equally_spaced(7.5u,0) z1,z2,z3;
L=0.5[z1,z2]; % location of spool
C=0.5[z2,z3]-(0,2u);
R=0.5[z2,z3]+(0,2u);
z4 = z3+(2.5u,0);
edraw; % draw elements of circuits
% draw wires connecting nodes
wire.v(Vac.a,z0);
wire.v(Vac.b,z1);
wire(z1,L.a);
wire(L.b,z2);
wire.v(z2,C.a);
wire.v(z2,R.a);
wire.v(z3,C.b);
wire.v(z3,R.b);
wire(z3,z4);
wire.v(z4,z0);
endfig;
end;