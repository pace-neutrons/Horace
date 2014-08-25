function v=read_sparse2(fid,varargin)
% Read sparse column vector of doubles written with write_sparse2
%
% Read whole array:
%   >> [v,ok,mess] = read_sparse2(fid)
%   >> [v,ok,mess] = read_sparse2(fid,skip)
%
% Read a section of the array:
%   >> [v,ok,mess] = read_sparse2(fid,type,nrange,irange)
%
% Input:
% ------
%   fid     File identifier of already open file for binary output
%   skip    [Optional] If true, move to the end of the data without reading
%           Default: read the data (skip==false)
% *OR*
%   type    Type of data stored ('int32','float32','float64')
%   nrange  Range of indicies of the array to be read
%   irange  Range of values actually written to file that encompass this range
%
%           This second read option requires prior knowledge of the type of data
%           in the file, and the range of non-zero values and their indicies that
%           are within the range nrange. If nrange==[], then it is assumed that
%           the 
%
% Output:
% -------
%   v       Column vector (sparse format)
%
% It is assumed that the file position indicator is at the start of the information
% written by write_sparse2.
%
% On exit, the file pointer will be be at the end of the information written by
% write_sparse2 in the case of reading the whole array; if reading an array section
% the indicator will be at the position of the end of the section.

% Make sure any changes here are synchronised with the corresponding read_sparse


% Check number of arguments
nopt=numel(varargin);
if nopt==3
    read_all=false;
    skip=false;
elseif nopt==0
    read_all=true;
    skip=false;
elseif nopt==1
    read_all=true;
    skip=logical(varargin{1});
else
    error('Check number of arguments')
end

% Read data sizes and type
if read_all
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
        v=sparse(double(val(1,:)),1,double(val(2,:)),nel,1);
    else
        v=sparse(double(val(1,:))-(nrange(1)-1),1,double(val(2,:)),nel,1);
    end
    
else
    fseek(fid,2*nval*abs(nbytecode),'cof');
    v=[];
end
