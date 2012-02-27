function test_deriv_1d
% Test of numerical differentiation for 1D workspace

% Create slightly noisy Gaussian
n=100;
fac=0.02;
xx=0.1*((1:n)/n) + sort(rand(1,n));
yy=exp(-0.5*((xx-0.5)/0.15).^2);
ee=fac*(1+2*rand(1,n));       % in range fac to 3*fac
yy=yy+ee-1.5*fac;
ee=fac*(1+rand(1,n))/2;       % in range fac/2 to fac

w=IX_dataset_1d(xx,yy,ee);

% Take derivative
wd=deriv(w);

% Plot
acolor k
h1=dd(w);
acolor r
h2=pd(wd);

assertEqual(h1,h2);
pause(2);
close(h1)

