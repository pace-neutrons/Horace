function testbin
%
% function to create a small test bin file

fout= 'C:\Documents and Settings\jv53\My Documents\Joost\Data\TbMnO3\experiment\test.bin';

% use the the run 7576 to construct a small data set. 

data= fromwindow;
data.a= 5.31;
data.b= 5.81;
data.c= 7.39;
data.alpha= 90;
data.beta= 90;
data.gamma= 90;
data.u1= [1 0 0 0];
data.u2= [0 1 0 0];
data.u3= [0 0 1 0];
data.u4= [0,0,0,1]; % energy
data.nfiles= 1;
writeheader(data,fout);

fid=fopen(fout, 'r+');
fseek(fid, 0, 'eof');

fwrite(fid, 5, 'float32');
fwrite(fid, [0 1 0], 'float32');
fwrite(fid, [0 0 1], 'float32');
fwrite(fid, 5, 'int32');
fwrite(fid, 'test1', 'char');
sized= [4 5]
fwrite(fid,sized,'int32');
temp=data.v(2000:2003,39:43,:); % select a small hkl array
temp=reshape(temp,20,3);
temp=temp';
fwrite(fid,temp,'float32');
fwrite(fid, data.en(39:43), 'float32');
temp=data.S(2000:2003,39:43);
temp=reshape(temp,20,1);
temp=temp';
fwrite(fid,temp,'float32');
temp=data.ERR(2000:2003,39:43);
temp=reshape(temp,20,1);
temp=temp';
fwrite(fid,temp,'float32');
fclose(fid);
