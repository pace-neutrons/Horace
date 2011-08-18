function y=func_gauss3d(x1,x2,x3,par)
% 3D Gaussian without corelations
%
%   par=[ht,x0,y0,z0,sigx,sigy,sigz]

ht=par(1);
x0=par(2);
y0=par(3);
z0=par(4);
sigx=par(5);
sigy=par(6);
sigz=par(7);
y=ht*exp(-0.5*(((x1-x0)/sigx).^2+((x2-y0)/sigy).^2+((x3-z0)/sigz).^2));
