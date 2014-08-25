function v=read_sparse(fid,skip)
% Read sparse column vector of doubles written with write_sparse
%
%   >> [v,ok,mess] = read_sparse(fid)
%   >> [v,ok,mess] = read_sparse(fid,skip)
%
% Input:
% ------
%   fid     File identifier of already open file for binary output
%   skip    [Optional] If true, move to the end of the data without reading
%           Default: read the data (skip==false)
%
% Output:
% -------
%   v       Column vector (sparse format)
%
% It is assumed that the file position indicator is at the start of the information
% written by write-sparse2.

% Make sure any changes here are synchronised with the corresponding read_sparse


% Check arguments
if nargin==2
    if ~islogical(skip), skip=logical(skip); end
elseif nargin==1
    skip=false;
end

% Read data sizes and type
n = fread(fid,3,'float64');
nel=n(1);
nval=n(2);
nbytecode=n(3);

% Read or skip over data
if ~skip
    % Read indicies
    if nel>=intmax('int32')
        ind = fread(fid,[nval,1],'*int64');
    else
        ind = fread(fid,[nval,1],'*int32');
    end
    
    % Read values
    if nbytecode==4
        val = fread(fid,[nval,1],'*float32');
    elseif nbytecode==8
        val = fread(fid,[nval,1],'*float64');
    elseif nbytecode==-4
        val = fread(fid,[nval,1],'*int32');
    end
    
    % Construct sparse column vector
    v=sparse(double(ind),1,double(val),nel,1);
    
else
    % Skip over the data, if requested, but position at end of the data
    if nel>=intmax('int32')
        nbytes=nval*(8+abs(nbytecode));
    else
        nbytes=nval*(4+abs(nbytecode));
    end
    fseek(fid,nbytes,'cof');
    v=[];
end
