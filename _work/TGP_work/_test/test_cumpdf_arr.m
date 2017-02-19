%% Test the cumulative pdf array lookup

% Three probability distribution lookup tables

x1=5:0.01:15;
xc=9; sig=1;
y1=exp(-0.5*((x1-xc)/sig).^2);
y1(1)=0; y1(end)=0;
w1=IX_dataset_1d(x1,y1);

x2=-1:0.002:1;
y2=trapezium(x2,0.1,0.4,0.5,4);
x2=x2+4;
w2=IX_dataset_1d(x2,y2);

x3=0:0.015:15;
tauf=0.4; taus=0.8; R=0.4;
y3=ikcarp (x3, tauf, taus, R);
y3(1)=0; y3(end)=0;
w3=IX_dataset_1d(x3,y3);

npnt=500;
xtab1=sampling_table(x1,y1,npnt);
xtab2=sampling_table(x2,y2,npnt);
xtab3=sampling_table(x3,y3,npnt);


% Now check the sampling tables
xtab=[xtab1,xtab2,xtab3];

nx=20000; ny=5000;
ind=1+round(2*rand(nx,ny));

tic
X = rand_cumpdf_arr(xtab,ind);
toc

bn=0:0.01:15;
ww1=IX_dataset_1d(bn,histc(make_column(X(ind==1)),bn));
ww2=IX_dataset_1d(bn,histc(make_column(X(ind==2)),bn));
ww3=IX_dataset_1d(bn,histc(make_column(X(ind==3)),bn));



acolor r b k
dl([w1,w2,w3])
keep_figure
dh([ww1,ww2,ww3])

