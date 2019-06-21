x1=1:0.2:10;
x2=11:0.2:20;
[xx1,xx2]=ndgrid(x1,x2);
y=gauss2d(xx1,xx2,[100,5,15,4,0,4]);

c = contourc (x1,x2,y,[50,50]);

xc=c(1,2:end);
yc=c(2,2:end);

d2=IX_dataset_2d(x1,x2,y);
plot(d2);
hold on
plot(xc,yc,'-')

