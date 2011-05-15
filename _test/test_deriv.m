% Create arrays to test differentiation
n=100;
fac=0.02;
xx=0.1*((1:n)/n) + sort(rand(1,n));
yy=exp(-0.5*((xx-0.5)/0.15).^2);
ee=fac*(1+2*rand(1,n));       % in range fac to 3*fac
noise=ee-2*fac;               % in range -fac to fac
yy=yy+ee-1.5*fac;
ee=fac*(1+rand(1,n))/2;       % in range fac/2 to fac


w=IX_dataset_1d(xx,yy,ee);

[yd,ed] = yderiv_mgenie(xx,yy,ee);
wm=IX_dataset_1d(xx,yd,ed);

[yd,ed] = yderiv(xx,yy,ee);
wd=IX_dataset_1d(xx,yd,ed);


acolor k
dd(w)
acolor r
pl(wd)
acolor b
pl(wm)

