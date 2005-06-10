function test_slice3d (data, p1_lo, p1_hi, p2_lo, p2_hi, p3_lo, p3_hi, imin, imax)
% test function to send a 3d slice obtained from the large block bin file
% to sliceomatic


lx = find(data.u1>=p1_lo & data.u1<p1_hi);
ly = find(data.u2>=p2_lo & data.u2<p2_hi);
lz = find(data.u3>=p3_lo & data.u3<p3_hi);
v= data.int(lx,ly,lz);
nv=double(data.nint(lx,ly,lz));

% normalize int to number of pixels contributing to it. 
lis= find(nv~=0);
v(lis)= v(lis)./nv(lis);

% set min and max intensity values.
v(find(v<imin))=imin;
v(find(v>imax))=imax;

x = data.u1(lx(1):lx(end));
y = data.u2(ly(1):ly(end));
z = data.u3(lz(1):lz(end));

sliceomatic(v,y,x,z);