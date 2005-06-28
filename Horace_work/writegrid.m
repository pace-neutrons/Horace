function writegrid(data,fout),

% This routine writes the following data structure out to a binary file
% called fout.
%
% data:
%       data.nhv = length(data.hv)  : number of grid boundaries along Q_h
%       data.nkv = length(data.kv)  : number of grid boundaries along Q_k
%       data.nlv = length(data.lv)  : number of grid boundaries along Q_l
%       data.nev = length(data.ev)  : number of grid boundaries along E
%       data.hv                : grid boundaries along Q_h
%       data.kv                : grid boundaries along Q_k
%       data.lv                : grid boundaries along Q_l
%       data.ev                : grid boundaries along E
%       data.rint(length(data.hv),length(data.kv),length(data.lv),length(data.ev)) float32
%       data.eint(length(data.hv),length(data.kv),length(data.lv),length(data.ev)) float32
%       data.nint(length(data.hv),length(data.kv),length(data.lv),length(data.ev)) int16
%
%       data.rint is the cumulative intensity in the grid defined by the bin boundaries 
%       in data.hv,data.kv,data.lv,data.ev.
%       data.eint is the cumulative variance in the grid defined by the bin boundaries 
%       in data.hv,data.kv,data.lv,data.ev.
%       Number of pixels that contributed to a grid point is given by data.nint

% Author:
%   J. van Duijn     12/06/2005
% Modified:
%
% Horace v0.1   J.Van Duijn, T.G.Perring

disp('Writing binary file ...')
writeheader(data,fout);
fid = fopen(fout,'r+');
fseek(fid, 0, 'eof');
if length(data.pax)==4, % 4D grid
    np1=length(data.p1); % length of vector data.p1
    fwrite(fid,np1,'int32');
    np2=length(data.p2); % length of vector data.p2
    fwrite(fid,np2,'int32');
    np3=length(data.p3); % length of vector data.p3
    fwrite(fid,np3,'int32');
    np4=length(data.p4); % length of vector data.p4
    fwrite(fid,n4,'int32');
    fwrite(fid,data.p1,'float32');
    fwrite(fid,data.p2,'float32');
    fwrite(fid,data.p3,'float32');
    fwrite(fid,data.p4,'float32');
elseif length(data.pax)==3, %3D grid
    np1=length(data.p1); % length of vector data.p1
    fwrite(fid,np1,'int32');
    np2=length(data.p2); % length of vector data.p2
    fwrite(fid,np2,'int32');
    np3=length(data.p3); % length of vector data.p3
    fwrite(fid,np3,'int32');
    fwrite(fid,data.p1,'float32');
    fwrite(fid,data.p2,'float32');
    fwrite(fid,data.p3,'float32');
elseif length(data.pax)==2, %2D grid
    np1=length(data.p1); % length of vector data.p1
    fwrite(fid,np1,'int32');
    np2=length(data.p2); % length of vector data.p2
    fwrite(fid,np2,'int32');
    fwrite(fid,data.p1,'float32');
    fwrite(fid,data.p2,'float32');
elseif length(data.pax)==2, %1D grid
    np1=length(data.p1); % length of vector data.p1
    fwrite(fid,np1,'int32');
    fwrite(fid,data.p1,'float32');
else
    disp(['ERROR! Wrong type of data structure']);
end
fwrite(fid,data.s,'float32');
fwrite(fid,data.e,'float32');
fwrite(fid,data.n,'int16');
fclose(fid);