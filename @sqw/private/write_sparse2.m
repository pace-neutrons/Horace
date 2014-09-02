function write_sparse2(fid,v,type)
% Write sparse column vector of doubles designed for swifter reading of sections
%
%   >> write_sparse2(fid,v,type)
%
% Input:
% ------
%   fid     File identifier of already open file for binary output
%   v       Values to be written
%   type    Data type in which to save indicies and values: one of:
%
% Limitations on the values array:
%
%   type      maximum array length          value type
% --------------------------------------------------------------------
% 'int32'   2,147,483,647  (2^31-1)         -(2^31)<= integer =< (2^31)-1
%
% 'float32'    16,777,216  (2^24)           float (written in single precision)
%                                         or  |integer| < 16,777,216  (ie. 2^24)
%
% 'float64'  281,474,976,710,655 (2^48-1)   float (written in double precision)
%                                         or  |integer| 9.0072e+15  (ie. 2^53)
%
% This form of sparse writing enables faster reading of sections from a large
% array because the indicies and values are stored in adjacent words of
% 4 or 8 bytes.

% Make sure any changes here are synchronised with the corresponding read_sparse2


% Original author: T.G.Perring
%
% $Revision: 890 $ ($Date: 2014-08-31 16:32:12 +0100 (Sun, 31 Aug 2014) $)


% Check type is valid
if strcmp(type,'float32')
    nbytecode=4;
elseif strcmp(type,'float64')
    nbytecode=8;
elseif strcmp(type,'int32')
    nbytecode=-4;
else
    error('Unrecognised type')
end

% Write nbits and data sizes
nel=size(v,1);
[ind,~,val]=find(v);
nval=numel(val);            % number of non-zero values
fwrite(fid,[nel,nval,nbytecode],'float64');

% Write non-zero values
if nbytecode==4
    fwrite(fid,single([ind';val']),'float32');
elseif nbytecode==8
    fwrite(fid,[ind';val'],'float64');
elseif nbytecode==-4
    fwrite(fid,int32([ind';val']),'int32');
end
