function v=read_sparse2(fid,varargin)
% Read sparse column vector of doubles written with write_sparse2
%
% Read whole array:
%   >> v = read_sparse2(fid)
%   >> v = read_sparse2(fid,makefull)
%
% Read a section of the array:
%   >> v = read_sparse2(fid,type,nrange,irange)
%   >> v = read_sparse2(fid,type,nrange,irange,makefull)
%
% Skip over the data
%   >> ... = read_sparse2(...,'skip')
%
% Input:
% ------
%   fid         File identifier of already open file for binary output
%   makefull    [Optional]  =true return array in full format; =false leave as sparse
%               Default: false
%  'skip'       [Optional] If present, move to the end of the data without reading
%               Default: read the data (skip==false)
% *OR*
%   type        Type of data stored ('int32','float32','float64')
%   nrange      Range of indicies of the array to be read
%   irange      Range of values actually written to file that encompass this range
%   full        [Optional] If true, return array as full array***
%   makefull    [Optional]  =true return array in full format; =false leave as sparse
%               Default: false
%
%               This second read option requires prior knowledge of the type of data
%               in the file, and the range of non-zero values and their indicies that
%               are within the range nrange.
%
% Output:
% -------
%   v       Column vector (sparse format)
%
%
% It is assumed that the file position indicator is at the start of the information
% written by write_sparse2.
%
% On exit, the file pointer will be be at the end of the information written by
% write_sparse2 in the case of reading the whole array; if reading an array section
% the indicator will be at the position of the end of the section.

% Make sure any changes here are synchronised with the corresponding read_sparse


% Original author: T.G.Perring
%
% $Revision: 890 $ ($Date: 2014-08-31 16:32:12 +0100 (Sun, 31 Aug 2014) $)


% Check arguments
nopt=numel(varargin);
if nopt==0 || nopt==3
    % Catch the most common case of no optional arguments
    makefull=false;
    skip=false;
    if nopt==0
        read_all=true;
    else
        read_all=false;
    end
else
    % One or both optional arguments
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
    if nopt>0 && islognumscalar(varargin{nopt})
        makefull=logical(varargin{nopt});
        nopt=nopt-1;
    else
        makefull=false;
    end
    if nopt==0
        read_all=true;
    elseif nopt==3
        read_all=false;
    else
        error('Check number of input arguments')
    end
end

% Read data sizes and type
if read_all || skip
    n = fread(fid,3,'float64');
    nel=n(1);
    nval=n(2);
    nbytecode=n(3);
else
    type=varargin{1};
    nrange=varargin{2};
    irange=varargin{3};
    nel=nrange(2)-nrange(1)+1;
    nval=irange(2)-irange(1)+1;
    if strcmp(type,'float32')
        nbytecode=4;
    elseif strcmp(type,'float64')
        nbytecode=8;
    elseif strcmp(type,'int32')
        nbytecode=-4;
    else
        error('Unrecognised type')
    end
    fseek(fid,24+2*(irange(1)-1)*abs(nbytecode),'cof');
end

% Read or skip over data
if ~skip
    if nbytecode==4
        val = fread(fid,[2,nval],'*float32');
    elseif nbytecode==8
        val = fread(fid,[2,nval],'*float64');
    elseif nbytecode==-4
        val = fread(fid,[2,nval],'*int32');
    end
    
    % Construct sparse column vector
    if read_all
        if makefull
            v=zeros(nel,1);
            v(val(1,:))=val(2,:);
        else
            v=sparse(double(val(1,:)),1,double(val(2,:)),nel,1);
        end
    else
        if makefull
            v=zeros(nel,1);
            v(val(1,:)-(nrange(1)-1))=val(2,:);
        else
            v=sparse(double(val(1,:))-(nrange(1)-1),1,double(val(2,:)),nel,1);
        end
    end
    
else
    fseek(fid,2*nval*abs(nbytecode),'cof');
    v=[];
end
