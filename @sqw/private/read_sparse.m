function v=read_sparse(fid,varargin)
% Read sparse column vector of doubles written with write_sparse
%
%   >> v = read_sparse(fid)
%   >> v = read_sparse(fid,makefull)      % return array in full format if full==true
%   >> v = read_sparse(...'skip')         % skip over the data
%
% Input:
% ------
%   fid         File identifier of already open file for binary output
%   makefull    [Optional] =true return array in full format; =false leave in sparse
%               Default: false
%  'skip'       [Optional] If present, move to the end of the data without reading
%               Default: read the data (skip==false)
%
% Output:
% -------
%   v           Column vector (sparse format)
%
%
% It is assumed that the file position indicator is at the start of the information
% written by write_sparse.

% Make sure any changes here are synchronised with the corresponding read_sparse


% Original author: T.G.Perring
%
% $Revision: 890 $ ($Date: 2014-08-31 16:32:12 +0100 (Sun, 31 Aug 2014) $)


% Check arguments
nopt=numel(varargin);
if nopt==0
    makefull=false;
    skip=false;
else
    if ischar(varargin{nopt})
        if strcmpi(varargin{nopt},'skip')
            skip=true;
        else
            error('Unrecognised option')
        end
        nopt=nopt-1;
    else
        skip=false;
    end
    if nopt==1
        makefull=logical(varargin{nopt});
    elseif nopt==0
        makefull=false;
    else
        error('Check number of input arguments')
    end
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
    
    % Construct column vector
    if makefull
        v=zeros(nel,1);
        v(ind)=val;
    else
        v=sparse(double(ind),1,double(val),nel,1);
    end
    
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
