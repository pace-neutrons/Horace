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
% 'int32'   2,147,483,647  (ie. (2^31)-1)   -(2^31)<= integer =< (2^31)-1
%
% 'float32'    16,777,216  (ie. 2^24)      float (written in single precision)
%                                         or  |integer| < 16,777,216  (ie. 2^24)
%
% 'float64'    9.0072e+15  (ie. 2^53)   float (written in double precision)
%                                         or  |integer| 9.0072e+15  (ie. 2^53)
%
% This fom of sparse writing enables faster reading of sections from a large
% array because the indicies and values are stored in adjacent words of
% 4 or 8 bytes.

% Make sure any changes here are synchronised with the corresponding read_sparse2


% Check type is valid
if strcmp(type,'float32')
    nbits=32;
elseif strcmp(type,'float64')
    nbits=64;
elseif strcmp(type,'int32')
    nbits=-32;
else
    error('Unrecognised type')
end

% Write nbits and data sizes
nel=size(v,1);
[ind,~,val]=find(v);
nval=numel(val);            % number of non-zero values
fwrite(fid,[nel,nval,nbits],'float64');

% Write indicies of non-zeros values (account for the possibility of more than 2e9 non-zero elements)
if nval>=intmax('int32')
    fwrite(fid,int64(ind),'int64');
else
    fwrite(fid,int32(ind),'int32');
end

% Write non-zero values
if nbits==32
    fwrite(fid,single([ind';val']),'float32');
elseif nbits==64
    fwrite(fid,single([ind';val']),'float64');
elseif nbits==-32
    fwrite(fid,int32([ind';val']),'int32');
end
