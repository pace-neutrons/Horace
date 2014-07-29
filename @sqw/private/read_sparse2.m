function [v,ok,mess]=read_sparse2(fid,skip)
% Read sparse column vector of doubles written with write_sparse2
%
%   >> [v,ok,mess] = read_sparse2(fid)
%   >> [v,ok,mess] = read_sparse2(fid,skip)
%   >> [v,ok,mess] = read_sparse2(fid,type,***)
%
% Input:
% ------
%   fid     File identifier of already open file for binary output
%   skip    [Optional] If true, move to the end of the data without reading
%           Default: read the data
%
% Output:
% -------
%   v       Column vector (sparse format)

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
nbits=n(3);

% Read or skip over data
if ~skip
    if nbits==32
        val = fread(fid,[2,nval],'*float32');
    elseif nbits==64
        val = fread(fid,[2,nval],'*float64');
    elseif nbits==-32
        val = fread(fid,[2,nval],'*int32');
    else
        error('Unrecognised type')
    end
    
    % Construct sparse column vector
    v=sparse(double(val(1,:)),1,double(val(2,:)),nel,1);
else
    if nbits==32
        nbytes=4*nval;
    elseif nbits==64
        nbytes=8*nval;
    elseif nbits==32
        nbytes=4*nval;
    else
        error('Unrecognised type')
    end
    fseek(fid,nbytes,'cof');  % skip field pix
    v=[];
    ok=true;
    mess='';
end
