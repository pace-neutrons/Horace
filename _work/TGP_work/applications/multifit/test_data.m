%% Test data types

% Some cell data
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

s1.x=x1; s1.y=y1; s1.e=e1;
s2.x=x2; s2.y=y2; s2.e=e2;
s3.x=x3; s3.y=y3; s3.e=e3;
sarr2=[s1,s2];
sarr3=[s1,s2,s3];

w1=IX_dataset_1d(x1,y1,e1);
w2=IX_dataset_1d(x2,y2,e2);
w3=IX_dataset_1d(x3,y3,e3);
warr2=[w1,w2];
warr3=[w1,w2,w3];

% Some invalid data

cbad={x1,y2,e2};
sbad=struct('x',x1,'y',y2);
wbad=herbert_config;
