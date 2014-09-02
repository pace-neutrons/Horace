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
%               'int32', 'float32', 'float64'
%
% If v is holding integers, then use:
%   - 'int32'   if the magnitude of the largest integer is <2e9
%   - 'float64' if the magnitude of the largest integer is <9e15
% 
% There is no advantage to saving the values as a hypothetical 'int64'
% because integer accuracy is already lost for values >9e15 if held as a float64.

% Make sure any changes here are synchronised with the corresponding read_sparse


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

% Write indicies of non-zeros values (account for the possibility of array length greater than 2e9)
if nel>=intmax('int32')
    fwrite(fid,int64(ind),'int64');
else
    fwrite(fid,int32(ind),'int32');
end

% Write non-zero values
if nbytecode==4
    fwrite(fid,single(val),'float32');
elseif nbytecode==8
    fwrite(fid,val,'float64');
elseif nbytecode==-4
    fwrite(fid,int32(val),'int32');
end
