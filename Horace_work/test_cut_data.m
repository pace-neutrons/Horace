%--------------------------------------------------------
% 2D :
%--------------------------------------------------------
din.file = 'c:\blobby.dat';
din.grid ='orthogonal-grid';
din.title = 'This is a silly test';
din.a = pi; din.b=pi; din.c=pi;
din.alpha = 90; din.beta=90; din.gamma=90;
din.u = [1,1,0,0; 0,0,1,0; 1,-1,0,0; 0,0,0,1];
din.ulen = [2.828427125, 2, 2.828427125, 1];
din.label = {'Q_hh','Q_l','Q_kbk','En'};
din.p0 = [3,1,4,10]';
din.pax = [2,4];
din.iax = [3,1];
din.uint = [0.45,0.9;0.55,1.1];
din.p1 = [1.1,1.2,1.3,1.4,1.5,1.6]';
din.p2 = [2.1,2.2,2.3,2.4]';

a=[1,2,3,4,5]';
b=[2,3,4];
sa=repmat(a,[1,3]);
sb=repmat(b,[5,1]);

din.s = sa+sb;
din.e = 2*din.s;
din.n = ones(size(din.s));

w2 = d2d(din);

%--------------------------------------------------------
narr=[400,250];
din.file = 'c:\blobby.dat';
din.grid ='orthogonal-grid';
din.title = 'This is a silly test';
din.a = pi; din.b=pi; din.c=pi;
din.alpha = 90; din.beta=90; din.gamma=90;
din.u = [1,1,0,0; 0,0,1,0; 1,-1,0,0; 0,0,0,1];
din.ulen = [2.828427125, 2, 2.828427125, 1];
din.label = {'Q_hh','Q_l','Q_kbk','En'};
din.p0 = [3,1,4,10]';
din.pax = [2,4];
din.iax = [3,1];
din.uint = [0.45,0.9;0.55,1.1];

ndim = length(narr);
if ndim>=1; din.p1 = linspace(1,5,narr(1)+1)'; end;
if ndim>=2; din.p2 = linspace(11,15,narr(2)+1)'; end;

din.s = rand(narr(1),narr(2));
din.e = 2*rand(narr(1),narr(2));
din.n = 10*rand(narr(1),narr(2));

w2 = d2d(din);

%--------------------------------------------------------
% 3D :
%--------------------------------------------------------

% Example to highlight deficiency of sliceomatic
nx = 6;
ny = 5;
nz = 3;
din.file = 'c:\blobby.dat';
din.grid ='orthogonal-grid';
din.title = 'This is a silly test';
din.a = pi; din.b=pi; din.c=pi;
din.alpha = 90; din.beta=90; din.gamma=90;
din.u = [1,1,0,0; -1,1,0,0; 0,0,1,0; 0,0,0,1]';
din.ulen = [2.828427125, 2.828427125, 2, 1];
din.label = {'Q_h','Q_k','Q_l','En'};
din.p0 = [2,1,1,0]';
din.pax = [3,4,1];
din.iax = [2];
din.uint = [0.45;0.55];
din.p1 = linspace(10,12,nx)';
din.p2 = linspace(20,24,ny)';
din.p3 = linspace(30,36,nz)';

din.s=zeros(nx-1,ny-1,nz-1);
for i=1:nx-1
    for j=1:ny-1
        for k=1:nz-1
            din.s(i,j,k) = j;
        end
    end
end
din.e = 2*din.s;
din.n = ones(size(din.s));

w3 = d3d(din);

%--------------------------------------------------------
narr=[250,50,200];
din.file = 'c:\blobby.dat';
din.grid ='orthogonal-grid';
din.title = 'This is a silly test';
din.a = pi; din.b=pi; din.c=pi;
din.alpha = 90; din.beta=90; din.gamma=90;
din.u = [1,1,0,0; -1,1,0,0; 0,0,1,0; 0,0,0,1]';
din.ulen = [2.828427125, 2.828427125, 2, 1];
din.label = {'Q_h','Q_k','Q_l','En'};
din.p0 = [2,1,1,0]';
din.pax = [3,4,1];
din.iax = [2];
din.uint = [0.45;0.55];

ndim = length(narr);
if ndim>=1; din.p1 = linspace(0,5,narr(1)+1)'; end;
if ndim>=2; din.p2 = linspace(-10,40,narr(2)+1)'; end;
if ndim>=3; din.p3 = linspace(-2,2,narr(3)+1)'; end;

pp1 = 0.5*(din.p1(1:end-1)+din.p1(2:end));
pp2 = 0.5*(din.p2(1:end-1)+din.p2(2:end));
pp3 = 0.5*(din.p3(1:end-1)+din.p3(2:end));
[pp1,pp2,pp3]=ndgrid(pp1,pp2,pp3);
wdisp = 10*(2*(sin(pi*pp3)).^2 + (sin(pi*pp1)).^2);

din.s = 400*exp(-(wdisp-pp2).^2);
din.e = din.s;
din.s = din.s + sqrt(din.e).*(randn(size(din.s)));
din.n = (50+floor(10*rand(narr(1),narr(2),narr(3))));

w3 = d3d(din);

%--------------------------------------------------------
% 4D :
%--------------------------------------------------------

narr=[50,50,50,40];
din.file = 'c:\blobby.dat';
din.grid ='orthogonal-grid';
din.title = 'This is a silly test';
din.a = pi; din.b=pi; din.c=pi;
din.alpha = 90; din.beta=90; din.gamma=90;
din.u = [1,0,0,0; 0,1,0,0; 0,0,1,0; 0,0,0,1]';
din.ulen = [2.828427125, 2.828427125, 2, 1];
din.label = {'Q_{h}','Q_{k}','Q_l','En'};
din.p0 = [0,0,0,0]';
din.pax = [1,2,3,4];
din.iax = [];
din.uint = [];

ndim = length(narr);
if ndim>=1; din.p1 = linspace(0,2,narr(1)+1)'; end;
if ndim>=2; din.p2 = linspace(0,2,narr(2)+1)'; end;
if ndim>=3; din.p3 = linspace(1,3,narr(3)+1)'; end;
if ndim>=4; din.p4 = linspace(0,40,narr(4)+1)'; end;

pp1 = 0.5*(din.p1(1:end-1)+din.p1(2:end));
pp2 = 0.5*(din.p2(1:end-1)+din.p2(2:end));
pp3 = 0.5*(din.p3(1:end-1)+din.p3(2:end));
pp4 = 0.5*(din.p4(1:end-1)+din.p4(2:end));
[pp1,pp2,pp3,pp4]=ndgrid(pp1,pp2,pp3,pp4);
wdisp = 10*((sin(pi*pp1)).^2 + (sin(pi*pp2)).^2 + (sin(pi*pp3)).^2);
clear pp1 pp2 pp3

din.s = 400*exp(-(wdisp-pp4).^2);
clear pp4 wdisp
din.e = din.s;
din.s = din.s + sqrt(din.e).*(randn(size(din.s)));
din.n = int16(50+floor(10*rand(narr(1),narr(2),narr(3),narr(4))));

w4 = d4d(din);

%---------------------------------------------------------------
tic
dout=section(din,[0.42,1.61],[0.43,1.62],[1.1,2.5],[5,35]);
toc
