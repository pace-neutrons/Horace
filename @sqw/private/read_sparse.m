function [v,ok,mess]=read_sparse(fid,skip)
% Read sparse column vector of doubles written with write_sparse
%
%   >> [v,ok,mess] = read_sparse(fid,skip)
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
if nargin==3
    if ~islogical(skip), skip=logical(skip); end
elseif nargin==2
    skip=false;
end

v=[];

% Read data type
nchar=fread(fid,1,'float64');
type=fread(fid,[1,nchar],'*char*1');

% Read data sizes
[nel,count,ok,mess] = fread_catch(fid,1,'float64'); if ~all(ok); return; end;
[nval,count,ok,mess] = fread_catch(fid,1,'float64'); if ~all(ok); return; end;

% Read or skip over data
if ~skip
    % Read data
    % Account for the possibility of more than 2e9 non-zero elements
    if nval>=intmax('int32')
        [ind,count,ok,mess] = fread_catch(fid,[nval,1],'*int64'); if ~all(ok); return; end;
    else
        [ind,count,ok,mess] = fread_catch(fid,[nval,1],'*int32'); if ~all(ok); return; end;
    end
    
    % Read values
    if strcmp(type,'float32')
        [val,count,ok,mess] = fread_catch(fid,[nval,1],'*float32'); if ~all(ok); return; end;
    elseif strcmp(type,'int32')
        [val,count,ok,mess] = fread_catch(fid,[nval,1],'*int32'); if ~all(ok); return; end;
    elseif strcmp(type,'float64')
        [val,count,ok,mess] = fread_catch(fid,[nval,1],'*float64'); if ~all(ok); return; end;
    elseif strcmp(type,'int64')
        [val,count,ok,mess] = fread_catch(fid,[nval,1],'*int64'); if ~all(ok); return; end;
    else
        error('Unrecognised type')
    end
    
    % Construct sparse column vector
    v=sparse(double(ind),1,double(val),nel,1);
else
    % Skip over the data, if requested, but position at end opf the data
    if nval>=intmax('int32')
        nbytes=8*nval;
    else
        nbytes=4*nval;
    end
    if strcmp(type,'float32')
        nbytes=nbytes+4*nval;
    elseif strcmp(type,'int32')
        nbytes=nbytes+4*nval;
    elseif strcmp(type,'float64')
        nbytes=nbytes+8*nval;
    elseif strcmp(type,'int64')
        nbytes=nbytes+8*nval;
    else
        error('Unrecognised type')
    end
    status=fseek(fid,nbytes,'cof');  % skip field pix
    v=[];
    ok=true;
    mess='';
end
