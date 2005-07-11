nl=100000;

m=rand(3,3);
tic
tt=rand(3,nl);
toc

tic
out=m*tt;
toc


out=rand(3,nl);
out(:,12345);
p=[1;2;3];
tic
% for i=1:3
%     out(i,:)=out(i,:)-p(i);
% end
out = out - repmat(p,1,nl);
toc
out(:,12345);

u1=linspace(1,10,10);
u2=linspace(2,30,10);
aa=find(u1<8)
bb=find(u2>3)

cc=find(u1<8&u2>3)


fid=fopen(fout, 'r'); % open bin file
data= getheader(fid); % get the main header information
data= getblock(fid);
fclose(fid);
