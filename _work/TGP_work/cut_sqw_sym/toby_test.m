xx=1:10;
yy=rand(1,10);
ee=rand(1,10);

ww=IX_dataset_1d(xx,yy,ee);
plot(ww)


ff=multifit2(ww);
ff=ff.set_fun(@linear_bg,[0,0]);

[wfit,fpar]=ff.fit;


