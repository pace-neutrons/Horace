function [data, mess] = get_grid_data (fid, ndim, arg1, arg2)
%  Read the grid data from a binary file created by slice_4d, slice_3d or writegrid.
%
% Syntax:
%   >> [data,mess] = get_grid_data (fid, ndim)             % read to new data structure
%   >> [data,mess] = get_grid_data (fid, ndim, data_in)    % append to existing data structure
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   ndim        Dimension of data arrays to read
%   data_in     (Optional) data structure to which the grid data fields below will be added
%   axes_only 	(Optional) if character string 'axes_only' then only read p1, p2, ... and
%              do not read s, e, n.
%
% Output:
% -------
%   data.p1     Column vector of bin boundaries along first plot axis
%   data.p2     Column vector of bin boundaries along second plot axis
%     :        (for as many plot axes as given by ndim)
%   data.s      Cumulative signal.  [size(data.s)=(length(data.p1)-1, length(data.p2)-1, ...)]
%   data.e      Cumulative variance [size(data.e)=(length(data.p1)-1, length(data.p2)-1, ...)]
%   data.n      Number of contributing pixels [size(data.n)=(length(data.p1)-1, length(data.p2)-1, ...)]
%              (if ndim=1,2 or 3, then data.n is double; if n=4 then data.n is int16)
%
%   mess        Error message; blank if no problems, non-blank otherwise

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

data = [];
axes_only = 0;

% Check input arguments:
if nargin<2; mess = 'ERROR: Check number of arguments to get_grid_data'; return; end
if nargin>=2 && ~isa_size(ndim,[1,1],'numeric'); mess = 'ERROR: Check input argument ''ndim'' is numeric'; return; end
if nargin==3
    if isstruct(arg1)
        data = arg1;
    elseif isa_size(arg1,'row','char') && strcmp(lower(arg1),'axes_only')
        axes_only = 1;
    else
        mess = 'ERROR: Check the type of third input argument to get_grid_data';
        return
    end
elseif nargin==4
    if isstruct(arg1) && (isa_size(arg2,'row','char') && strcmp(lower(arg2),'axes_only'))
        data = arg1;
        axes_only = 1;
    else
        mess = 'ERROR: Check the type(s) of third and fourth input arguments to get_grid_data';
        return
    end
end

% Read data
if ndim==4
    [np1,count,ok,mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [np2,count,ok,mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [np3,count,ok,mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [np4,count,ok,mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [data.p1,count,ok,mess] = fread_catch(fid,np1,'float32'); if ~all(ok); return; end;
    [data.p2,count,ok,mess] = fread_catch(fid,np2,'float32'); if ~all(ok); return; end;
    [data.p3,count,ok,mess] = fread_catch(fid,np3,'float32'); if ~all(ok); return; end;
    [data.p4,count,ok,mess] = fread_catch(fid,np4,'float32'); if ~all(ok); return; end;
    if axes_only; return; end;
    ntot = (np1-1)*(np2-1)*(np3-1)*(np4-1);
    data.s = zeros(np1-1,np2-1,np3-1,np4-1);
    data.e = zeros(np1-1,np2-1,np3-1,np4-1);
    data.n = zeros(np1-1,np2-1,np3-1,np4-1,'int16');
    [data.s,count,ok,mess] = fread_catch(fid,ntot,'float32'); if ~all(ok); return; end;
    data.s = reshape(data.s,np1-1,np2-1,np3-1,np4-1);
    [data.e,count,ok,mess] = fread_catch(fid,ntot,'float32'); if ~all(ok); return; end;
    data.e= reshape(data.e,np1-1,np2-1,np3-1,np4-1);
    [data.n,count,ok,mess] = fread_catch(fid,ntot,'int16'); if ~all(ok); return; end;
    data.n = int16(reshape(data.n,np1-1,np2-1,np3-1,np4-1));
elseif ndim==3
    [np1,count,ok,mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [np2,count,ok,mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [np3,count,ok,mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [data.p1,count,ok,mess] = fread_catch(fid,np1,'float32'); if ~all(ok); return; end;
    [data.p2,count,ok,mess] = fread_catch(fid,np2,'float32'); if ~all(ok); return; end;
    [data.p3,count,ok,mess] = fread_catch(fid,np3,'float32'); if ~all(ok); return; end;
    if axes_only; return; end;
    ntot = (np1-1)*(np2-1)*(np3-1);
    data.s = zeros(np1-1,np2-1,np3-1);
    data.e = zeros(np1-1,np2-1,np3-1);
    data.n = zeros(np1-1,np2-1,np3-1);
    [data.s,count,ok,mess] = fread_catch(fid,ntot,'float32'); if ~all(ok); return; end;
    data.s = reshape(data.s,np1-1,np2-1,np3-1);
    [data.e,count,ok,mess] = fread_catch(fid,ntot,'float32'); if ~all(ok); return; end;
    data.e = reshape(data.e,np1-1,np2-1,np3-1);
    [data.n,count,ok,mess] = fread_catch(fid,ntot,'double'); if ~all(ok); return; end;
    data.n= double(reshape(data.n,np1-1,np2-1,np3-1));
elseif ndim==2
    [np1,count,ok,mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [np2,count,ok,mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [data.p1,count,ok,mess] = fread_catch(fid,np1,'float32'); if ~all(ok); return; end;
    [data.p2,count,ok,mess] = fread_catch(fid,np2,'float32'); if ~all(ok); return; end;
    if axes_only; return; end;
    ntot = (np1-1)*(np2-1);
    data.s = zeros(np1-1,np2-1);
    data.e = zeros(np1-1,np2-1);
    data.n = zeros(np1-1,np2-1);
    [data.s,count,ok,mess] = fread_catch(fid,ntot,'float32'); if ~all(ok); return; end;
    data.s= reshape(data.s,np1-1,np2-1);
    [data.e,count,ok,mess] = fread_catch(fid,ntot,'float32'); if ~all(ok); return; end;
    data.e= reshape(data.e,np1-1,np2-1);
    [data.n,count,ok,mess] = fread_catch(fid,ntot,'double'); if ~all(ok); return; end;
    data.n = double(reshape(data.n,np1-1,np2-1));
elseif ndim==1
    [np1,count,ok,mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [data.p1,count,ok,mess] = fread_catch(fid,np1,'float32'); if ~all(ok); return; end;
    if axes_only; return; end;
    ntot = np1-1;
    data.s = zeros(np1-1);
    data.e = zeros(np1-1);
    data.n = zeros(np1-1);
    [data.s,count,ok,mess] = fread_catch(fid,ntot,'float32'); if ~all(ok); return; end;
    data.s = reshape(data.s,np1-1,1);
    [data.e,count,ok,mess] = fread_catch(fid,ntot,'float32'); if ~all(ok); return; end;
    data.e = reshape(data.e,np1-1,1);
    [data.n,count,ok,mess] = fread_catch(fid,ntot,'double'); if ~all(ok); return; end;
    data.n = double(reshape(data.n,np1-1,1));
elseif ndim==0
    if axes_only; return; end;
    [data.s,count,ok,mess] = fread_catch(fid,1,'float32'); if ~all(ok); return; end;
    [data.e,count,ok,mess] = fread_catch(fid,1,'float32'); if ~all(ok); return; end;
    [data.n,count,ok,mess] = fread_catch(fid,1,'double'); if ~all(ok); return; end;
else
    mess = 'Error: Check dimension of dataset';
    return
end