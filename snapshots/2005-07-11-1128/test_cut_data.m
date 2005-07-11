%---------------------------------------------------------
% 2D:
% ----
din.file = 'c:\blobby.dat';
din.title = 'This is a silly test';
din.a = pi; din.b=pi; din.c=pi;
din.alpha = 90; din.beta=90; din.gamma=90;
din.u = [1,1,0,0; 0,0,1,0; 1,-1,0,0; 0,0,0,1];
din.ulen = [2.828427125, 2, 2.828427125, 1];
din.label = {'Q_hh','Q_l','Q_kbk','En'};
din.p0 = [3,1,4,10];
din.pax = [2,4];
din.p1 = [1.1,1.2,1.3,1.4,1.5,1.6]';
din.p2 = [2.1,2.2,2.3,2.4]';
din.iax = [3,1];
din.uint = [0.45,0.9;0.55,1.1];
a=[1,2,3,4,5]';
b=[2,3,4];
sa=repmat(a,[1,3]);
sb=repmat(b,[5,1]);
din.s = sa+sb;
din.e = 2*din.s;
din.n = 10*din.s;

%--------------------------------------------------------
narr=[400,250];
din.file = 'c:\blobby.dat';
din.title = 'This is a silly test';
din.a = pi; din.b=pi; din.c=pi;
din.alpha = 90; din.beta=90; din.gamma=90;
din.u = [1,1,0,0; 0,0,1,0; 1,-1,0,0; 0,0,0,1];
din.ulen = [2.828427125, 2, 2.828427125, 1];
din.label = {'Q_hh','Q_l','Q_kbk','En'};
din.p0 = [3,1,4,10];
din.pax = [2,4];

ndim = length(narr);
if ndim>=1; din.p1 = linspace(1,5,narr(1)+1)'; end;
if ndim>=2; din.p2 = linspace(11,15,narr(2)+1)'; end;
if ndim>=3; din.p3 = linspace(21,25,narr(3)+1)'; end;
if ndim>=4; din.p4 = linspace(31,35,narr(4)+1)'; end;

din.iax = [3,1];
din.uint = [0.45,0.9;0.55,1.1];

din.s = rand(narr(1),narr(2));
din.e = 2*rand(narr(1),narr(2));
din.n = 10*rand(narr(1),narr(2));

%---------------------------------------------------------
% 3D:
% ----

% Example to highlight deficiency of sliceomatic
nx = 6
ny = 5
nz = 3
din.file = 'c:\blobby.dat';
din.title = 'This is a silly test';
din.a = pi; din.b=pi; din.c=pi;
din.alpha = 90; din.beta=90; din.gamma=90;
din.u = [1,1,0,0; -1,1,0,0; 0,0,1,0; 0,0,0,1]';
din.ulen = [2.828427125, 2.828427125, 2, 1];
din.label = {'Q_h','Q_k','Q_l','En'};
din.p0 = [2,1,1,0];
din.pax = [3,4,1];
din.p1 = linspace(10,12,nx)';
din.p2 = linspace(20,24,ny)';
din.p3 = linspace(30,36,nz)';
din.iax = [2];
din.uint = [0.45;0.55];


din.s=zeros(nx,ny,nz)
for i=1:nx
    for j=1:ny
        for k=1:nz
            din.s(i,j,k) = j;
        end
    end
end

din.e = 2*din.s;
din.n = ones(nx,ny,nz);


%--------------------------------------------------------
narr=[250,60,200];
din.file = 'c:\blobby.dat';
din.title = 'This is a silly test';
din.a = pi; din.b=pi; din.c=pi;
din.alpha = 90; din.beta=90; din.gamma=90;
din.u = [1,1,0,0; -1,1,0,0; 0,0,1,0; 0,0,0,1]';
din.ulen = [2.828427125, 2.828427125, 2, 1];
din.label = {'Q_h','Q_k','Q_l','En'};
din.p0 = [2,1,1,0];
din.pax = [3,4,1];

ndim = length(narr);
if ndim>=1; din.p1 = linspace(1,5,narr(1)+1)'; end;
if ndim>=2; din.p2 = linspace(-10,40,narr(2)+1)'; end;
if ndim>=3; din.p3 = linspace(-2,2,narr(3)+1)'; end;
if ndim>=4; din.p4 = linspace(31,35,narr(4)+1)'; end;

din.iax = [2];
din.uint = [0.45;0.55];

pp1 = 0.5*(din.p1(1:end-1)+din.p1(2:end));
pp2 = 0.5*(din.p2(1:end-1)+din.p2(2:end));
pp3 = 0.5*(din.p3(1:end-1)+din.p3(2:end));
[pp1,pp2,pp3]=ndgrid(pp1,pp2,pp3);
wdisp = 10*(2*(sin(pi*pp3)).^2 + (sin(pi*pp1)).^2);

din.s = 400*exp(-(wdisp-pp2).^2);
din.e = din.s;
din.s = din.s + sqrt(din.e).*(randn(size(din.s)));
din.n = int16(50+floor(10*rand(narr(1),narr(2),narr(3))));

%---------------------------------------------------------------
%---------------------------------------------------------------
% Miscellaneous tests
d3=readgrid('test3d.bin');
w1=cut_data(d3,1,[3,3.5],2,[3,3.5]);
w2=cut_data(d3,1,[2.5,4],2,[2.5,4]);


