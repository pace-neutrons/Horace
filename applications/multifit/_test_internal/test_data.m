%% Test data types

% Some 1D data sets
% -----------------
x1=1:0.1:10;
y1=gauss(x1,[100,5,1.2]);
e1=4*rand(size(y1));

x2=11:0.1:19;
y2=gauss(x2,[200,15,0.8]);
e2=6*rand(size(y2));

x3=15:0.1:23;
y3=gauss(x3,[150,19,0.7]);
e3=6*rand(size(y3));

c1={x1,y1,e1};
c2={x2,y2,e2};
c3={x3,y3,e3};
carr2={c1,c2};
carr3={c1,c2,c3};

cx1={{x1},y1,e1};
cx2={{x2},y2,e2};
cx3={{x3},y3,e3};
cxarr2={cx1,cx2};
cxarr3={cx1,cx2,cx3};

s1.x=x1; s1.y=y1; s1.e=e1;
s2.x=x2; s2.y=y2; s2.e=e2;
s3.x=x3; s3.y=y3; s3.e=e3;
sarr2=[s1,s2];
sarr3=[s1,s2,s3];

sx1.x={x1}; sx1.y=y1; sx1.e=e1;
sx2.x={x2}; sx2.y=y2; sx2.e=e2;
sx3.x={x3}; sx3.y=y3; sx3.e=e3;
sxarr2=[sx1,sx2];
sxarr3=[sx1,sx2,sx3];

w1=IX_dataset_1d(x1,y1,e1);
w2=IX_dataset_1d(x2,y2,e2);
w3=IX_dataset_1d(x3,y3,e3);
warr2=[w1,w2];
warr3=[w1,w2,w3];

% Some invalid data

cbad={x1,y2,e2};
sbad=struct('x',x1,'y',y2);
wbad=herbert_config;



% Some 2D data sets
% -----------------
ww1=make_test_IX_dataset_nd([10,15]);
ww2=make_test_IX_dataset_nd([12,8]);
ww3=make_test_IX_dataset_nd([14,6]);

wwarr2=[ww1,ww2];
wwarr3=[ww1,ww2,ww3];


[xx1,yy1]=ndgrid(ww1.x,ww1.y);
sig1=ww1.signal;
ee1=ww1.error;

[xx2,yy2]=ndgrid(ww2.x,ww2.y);
sig2=ww2.signal;
ee2=ww2.error;

[xx3,yy3]=ndgrid(ww3.x,ww3.y);
sig3=ww3.signal;
ee3=ww3.error;

cc1={cat(3,xx1,yy1),sig1,ee1};
cc2={cat(3,xx2,yy2),sig2,ee3};
cc3={cat(3,xx3,yy3),sig3,ee3};
ccarr2={cc1,cc2};
ccarr3={cc1,cc2,cc3};

ccx1={{xx1,yy1},sig1,ee1};
ccx2={{xx2,yy2},sig2,ee2};
ccx3={{xx3,yy3},sig3,ee3};
ccxarr2={ccx1,ccx2};
ccxarr3={ccx1,ccx2,ccx3};

ss1.x=cc1{1}; ss1.y=sig1; ss1.e=ee1;
ss2.x=cc2{1}; ss2.y=sig2; ss2.e=ee2;
ss3.x=cc3{1}; ss3.y=sig3; ss3.e=ee3;
ssarr2=[ss1,ss2];
ssarr3=[ss1,ss2,ss3];

ssx1.x=ccx1{1}; ssx1.y=sig1; ssx1.e=ee1;
ssx2.x=ccx2{1}; ssx2.y=sig2; ssx2.e=ee2;
ssx3.x=ccx3{1}; ssx3.y=sig3; ssx3.e=ee3;
ssxarr2=[ssx1,ssx2];
ssxarr3=[ssx1,ssx2,ssx3];


% % Huge array of large datasets
% % ----------------------------
% nd=1000;
% np=1e5;
% zarr=repmat(IX_dataset_1d,1,nd);
% for i=1:nd
%     zarr(i)=IX_dataset_1d(sort(rand(1,np)),rand(1,np),rand(1,np));
% end




