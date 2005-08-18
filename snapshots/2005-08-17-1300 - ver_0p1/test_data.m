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

% Example to highlight peculiarities of sliceomatic
nx = 8;
ny = 6;
nz = 4;

clear din
din.file = 'c:\blobby.dat';
din.grid ='orthogonal-grid';
din.title = 'This is a silly test';
din.a = pi; din.b=pi; din.c=pi;
din.alpha = 90; din.beta=90; din.gamma=90;
din.u = [1,0,0,0; 0,1,0,0; 0,0,1,0; 0,0,0,1]';
din.ulen = [1, 1, 1, 1];
din.label = {'Q_h','Q_k','Q_l','En'};
din.p0 = [2,1,1,0]';
din.pax = [1,2,3];
din.iax = [4];
din.uint = [10;12];
din.p1 = linspace(11,10+nx,nx)';
din.p2 = linspace(21,20+ny,ny)';
din.p3 = linspace(31,30+nz,nz)';

pc1 = 0.5*(din.p1(1:end-1)+din.p1(2:end));
pc2 = 0.5*(din.p2(1:end-1)+din.p2(2:end));
pc3 = 0.5*(din.p3(1:end-1)+din.p3(2:end));

% Get mesh of values for function evaluation:
[pp1,pp2,pp3]=ndgrid(din.p1,din.p2,din.p3);
[ppc1,ppc2,ppc3]=ndgrid(pc1,pc2,pc3);

nsx=nx-1; nsy=ny-1; nsz=nz-1;
din.s=zeros(nsx,nsy,nsz);
for i=1:nsx
    for j=1:nsy
        for k=1:nsz
%            din.s(i,j,k) = i+j+k;      % tests of slice plotting
            din.s = 0.5*(ppc3-30) + exp( -((ppc1-16.5).^2 + (ppc2-22.5).^2) ); % for isosurfacing tests; centred on (16.5,22.5)
%            if abs(i-6) < 1.5 & abs(j-3) < 1.5 & abs(k-1) < 1.5; din.s(i,j,k)=1; end; if i==6 & j==3 & k==1; din.s(i,j,k)=2; end; % peak at point (6,3,1)
        end
    end
end
din.e = 2*din.s;
din.n = ones(size(din.s));

w3 = d3d(din);

% Add the bin centres to the data structure for tests
pc1 = 0.5*(din.p1(1:end-1)+din.p1(2:end));
pc2 = 0.5*(din.p2(1:end-1)+din.p2(2:end));
pc3 = 0.5*(din.p3(1:end-1)+din.p3(2:end));
din.pc1=pc1;
din.pc2=pc2;
din.pc3=pc3;
din.pp1=pp1;
din.pp2=pp2;
din.pp3=pp3;
din.ppc1=ppc1;
din.ppc2=ppc2;
din.ppc3=ppc3;

%--------------------------------------------------------
% Number of bins the ranges below
narr=[250,50,200];
% first and last bin boundary values
p1_lim = [0,5];   
p2_lim = [-10,40];
p3_lim = [-2,2];

clear din
din.file = 'c:\blobby.dat';
din.grid ='orthogonal-grid';
din.title = 'This is a silly test';
din.a = pi; din.b=pi; din.c=pi;
din.alpha = 90; din.beta=90; din.gamma=90;
din.u = [1,1,0,0; -1,1,0,0; 0,0,1,0; 0,0,0,1]';
din.ulen = [2.828427125, 2.828427125, 2, 1];
din.label = {'Q_{hh}','Q_{kk}','Q_l','En'};
din.p0 = [2,1,1,0]';
din.pax = [3,4,1];
din.iax = [2];
din.uint = [0.45;0.55];
din.p1 = linspace(p1_lim(1),p1_lim(2),narr(1)+1)';
din.p2 = linspace(p2_lim(1),p2_lim(2),narr(2)+1)';
din.p3 = linspace(p3_lim(1),p3_lim(2),narr(3)+1)';

% Get bin centres:
pp1 = 0.5*(din.p1(1:end-1)+din.p1(2:end));
pp2 = 0.5*(din.p2(1:end-1)+din.p2(2:end));
pp3 = 0.5*(din.p3(1:end-1)+din.p3(2:end));

% Get mesh of values for function evaluation:
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

% Number of bins the ranges below
narr=[50,50,50,40]; 
% first and last bin boundary values
p1_lim = [0,2];   
p2_lim = [0,2];
p3_lim = [1,3];
p4_lim = [0,40];

clear din
din.file = 'c:\blobby.dat';
din.grid ='orthogonal-grid';
din.title = 'This is a silly test';
din.a = pi; din.b=pi; din.c=pi;
din.alpha = 90; din.beta=90; din.gamma=90;
din.u = [1,0,0,0; 0,1,0,0; 0,0,1,0; 0,0,0,1]';
din.ulen = [2, 2, 2, 1];
din.label = {'Q_{h}','Q_{k}','Q_l','En'};
din.p0 = [0,0,0,0]';
din.pax = [1,2,3,4];
din.iax = [];
din.uint = [];
din.p1 = linspace(p1_lim(1),p1_lim(2),narr(1)+1)';
din.p2 = linspace(p2_lim(1),p2_lim(2),narr(2)+1)';
din.p3 = linspace(p3_lim(1),p3_lim(2),narr(3)+1)';
din.p4 = linspace(p4_lim(1),p4_lim(2),narr(4)+1)';

% Get bin centres:
pp1 = 0.5*(din.p1(1:end-1)+din.p1(2:end));
pp2 = 0.5*(din.p2(1:end-1)+din.p2(2:end));
pp3 = 0.5*(din.p3(1:end-1)+din.p3(2:end));
pp4 = 0.5*(din.p4(1:end-1)+din.p4(2:end));
% Get mesh of values for function evaluation:
[pp1,pp2,pp3,pp4]=ndgrid(pp1,pp2,pp3,pp4);


wdisp = 10*((sin(pi*pp1)).^2 + (sin(pi*pp2)).^2 + (sin(pi*pp3)).^2);
din.s = 400*exp(-(wdisp-pp4).^2);
clear pp1 pp2 pp3 pp4 wdisp

din.e = din.s;
din.s = din.s + sqrt(din.e).*(randn(size(din.s)));
din.n = int16(50+floor(10*rand(narr(1),narr(2),narr(3),narr(4))));

w4 = d4d(din);

