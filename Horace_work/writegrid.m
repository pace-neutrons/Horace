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
fwrite(fid,data.nhv,'float32');
fwrite(fid,data.nkv,'float32');
fwrite(fid,data.nlv,'float32');
fwrite(fid,data.nev,'float32');
fwrite(fid,data.hv,'float32');
fwrite(fid,data.kv,'float32');
fwrite(fid,data.lv,'float32');
fwrite(fid,data.ev,'float32');
fwrite(fid,data.int,'float32');
fwrite(fid,data.err,'float32');
fwrite(fid,data.nint,'int16');
fclose(fid);