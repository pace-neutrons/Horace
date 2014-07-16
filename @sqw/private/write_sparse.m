function write_sparse(fid,v,type)
% Write sparse column vector of doubles.
%
%   >> write_sparse(fid,v,type)
%
% Input:
% ------
%   fid     File identifier of already open file for binary output
%   v       Values to be written
%   type    Data type in which to save values: one of
%               'float32', 'int32', 'float64', 'int64'
%
% Make sure any changes here are synchronised with the corresponding read_sparse in get_sqw_data

% Check type is valid, and write to file
if ischar(type) && (strcmp(type,'float32')||strcmp(type,'int32')||strcmp(type,'float64')||strcmp(type,'int64'))
    fwrite(fid,length(type),'float64');
    fwrite(fid,type,'char*1');
else
    error('Unrecognised type')
end

% Write data sizes
nel=size(v,1);
fwrite(fid,nel,'float64');  % write number of elements in the array (including zeros)
[ind,~,val]=find(v);
nval=numel(val);            % number of non-zero values
fwrite(fid,nval,'float64');

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
