function write_sparse2(fid,v,type)
***
% Write sparse column vector of doubles, assumed to contain integer values
% This is a specialised version of write_sparse designed for swifter reading or portions
%
%   >> write_sparse2(fid,v,type)
%
% Input:
% ------
%   fid     File identifier of already open file for binary output
%   v       Values to be written
%   type    Data type in which to save indicies and values: one of
%               'int32', 'int64'
%           The indicies of non-zero values and the values are both written
%          in the same data type. If there are more than 2e9 data elements
%          or the values lie outside the range -2e9 to +2e9 then the
%          saved data will be corrupt.
%
% This fom of sparse writing enables faster reading of the data from a large
% array because the indicies and values are stored in adjacent words of
% 4 or 8 bytes.
%
% Make sure any changes here are synchronised with the corresponding read_sparse2

if ~(strcmp(type,'float32')||strcmp(type,'float64'))
    error('Unrecognised type')
end

nel=size(v,1);
fwrite(fid,nel,type);   % write number of elements in the array (including zeros)
[ind,~,val]=find(v);
nval=numel(val);    	% number of non-zero values
fwrite(fid,nval,type);

% Write indicies of non-zeros values (account for the possibility of more than 2e9 non-zero elements)
if nval>=intmax('int32')
    fwrite(fid,int64(ind),'int64');
else
    fwrite(fid,int32(ind),'int32');
end

% Write non-zero values
if strcmp(type,'float32')
    fwrite(fid,single(val),'float32');
elseif strcmp(type,'int32')
    fwrite(fid,int32(val),'int32');
elseif strcmp(type,'float64')
    fwrite(fid,val,'float64');
elseif strcmp(type,'int64')
    fwrite(fid,int64(val),'int64');
else
    error('Unrecognised type')
end
