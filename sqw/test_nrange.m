% ==================================
% test find_irange_rot
% ==================================
nn=5;
urange=[0,2;0,2;0,2]';
rot=[1,1,0;-1,1,0;0,0,1]/sqrt(2);
trans=[0,1,0];

p1=0:1/nn:2;
p2=0:1/nn:2;
p3=0:1/nn:2;
nel=length(p1)*length(p2)*length(p3)
tic;
[istart,iend,inside] = get_irange_rot(urange,rot,trans,p1,p2,p3);
toc;

% ==================================
% test find_irange
% ==================================

nelmts=ones(3,5,6);
irange = [1,3;4,5;2,4]';
[ns,ne] = get_nrange(nelmts,irange)

%--------------------------------------------------
urange = [1,3;2,6]';
clear p
p{1}=0:0.5:4;
p{2}=1:0.5:8;
sz=zeros(1,length(p));
for i=1:length(p)
    sz(i)=length(p{i})-1;
end
nelmts=ones(sz);
[nstart,nend] = get_nrange_section (urange,nelmts,p{:});
nstart'
nend'


%--------------------------------------------------
urange = [1,3;2,6;3.1,5; 4.3,7]';
clear p
p{1}=0:0.5:4;
p{2}=1:0.5:8;
p{3}=2:0.5:4;
p{4}=[5,6];
sz=zeros(1,length(p));
for i=1:length(p)
    sz(i)=length(p{i})-1;
end
nelmts=ones(sz);
trans=[0,0,0];
rot=eye(3);


[nstart,nend] = get_nrange_section (urange,nelmts,p{:});
nstart'
nend'

[ns,ne] = get_nrange_rot_section (urange,rot,trans,nelmts,p{:});
ns'
ne'

disp([num2str(min(nstart'-ns')),'  ',num2str(max(nstart'-ns'))]
disp([num2str(min(nend'-ne')),'  ',num2str(max(nend'-ne'))]

% ==================================
% test get_nrange_rot_section
% ==================================
nn=5;

urange=[0,2;0,2;0,2;0.05,1.95]';
rot=[1,1,0;-1,1,0;0,0,1]/sqrt(2);
trans=[0,1,0];

p{1}=0:2/nn:2;
p{2}=0:2/nn:2;
p{3}=0:2/nn:2;
p{4}=0:2/nn:2;

sz=zeros(1,length(p));
for i=1:length(p)
    sz(i)=length(p{i})-1;
end
nelmts=ones(sz);

tic;
[ns,ne] = get_nrange_rot_section (urange,rot,trans,nelmts,p{:});
toc;
