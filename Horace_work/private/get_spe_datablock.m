function [data, mess] = get_spe_datablock (fid, arg1, arg2)
%  Read the a block of data corresponding to one .spe file from a binary file created
% by gen_hkle.
%
% Syntax:
%   >> [data,mess] = get_spe_datablock (fid)            % read to new data structure
%   >> [data,mess] = get_spe_datablock (fid, data_in)   % append to existing data structure
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   data_in     [optional] Data structure to which the grid data
%              fields below will be added.
%   axis        [optional] Axis and data limits along which to take a section of the data
%              axis = iax  Data returned corresponding to increasing order of
%                          component along axis iax (1<=iax<=4)
%              axis = [iax, v_lo, v_hi]  As above, where only a subset of the data
%                          is returned which is guaranteed to contain all pixels
%                          with component along axis iax in the range v_lo to v_hi
%                          [Note: there may additional pixels as well]
%
% Output:
% -------
%   data.ei     Incident energy used for spe file (meV)
%   data.psi    Psi angle (deg)
%   data.cu     u crystal axis (r.l.u.) (see mslice) [row vector]
%   data.cv     v crystal axis (r.l.u.) (see mslice) [row vector]
%   data.file   File name of .spe file corresponding to the block being read
%   data.size   size(1)=number of detectors; size(2)=number of energy bins [row vector]
%   data.en     Vector containing the energy bin centres [row vector]
%   data.v      Array containing the components along the mslice projection
%              axes u1, u2, u3, u4(==energy) for each pixel in the .spe file.
%              Note: size(data.v) = [4, no. dets * no. energy bins]
%   data.S      Intensity vector [row vector]
%   data.ERR    Variance vector [row vector]
%
%   mess        Error message; blank if all is OK, non-blank otherwise
%

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

% Check type of input arguments
if nargin==2 && isstruct(arg1)
    data = arg1;
elseif nargin==2 && (isa_size(arg1,[1,1],'double') | isa_size(arg1,[1,3],'double'))
    axis = arg1;
elseif nargin==3 && isstruct(arg1) && (isa_size(arg2,[1,1],'double') | isa_size(arg2,[1,3],'double'))
    data = arg1;
    axis = arg2;
elseif nargin~=1
    mess = 'ERROR: Check the input argument(s)';
    return
end

if exist('axis','var')
    iax = axis(1);
    if iax<1 | iax>4
        mess = 'ERROR: Axis label must be in range 1 - 4';
        return
    end
    if length(axis)==3
        vlo = axis(2);
        vhi = axis(3);
    else
        vlo = -inf;
        vhi = inf;
    end
else
    iax = 4;   % default is energy axis
    vlo = -inf;
    vhi = inf;
end

[data.ei,count,ok,mess] = fread_catch(fid, 1, 'float32'); if ~all(ok); return; end;
[data.psi,count,ok,mess] = fread_catch(fid, 1, 'float32'); if ~all(ok); return; end;
[data.cu,count,ok,mess] = fread_catch(fid, [1,3], 'float32'); if ~all(ok); return; end;
[data.cv,count,ok,mess] = fread_catch(fid, [1,3], 'float32'); if ~all(ok); return; end;
[n,count,ok,mess] = fread_catch(fid, 1, 'int32'); if ~all(ok); return; end;
[data.file,count,ok,mess] = fread_catch(fid, [1,n], '*char'); if ~all(ok); return; end;
[data.size,count,ok,mess] = fread_catch(fid, [1,2], 'int32'); if ~all(ok); return; end;
ndet = data.size(1);
ne = data.size(2);
nt= data.size(1)*data.size(2);
[data.en,count,ok,mess] = fread_catch(fid, [1,ne], 'float32'); if ~all(ok); return; end;

% Now jump to relevant part of file depending on the axis given; if none then assume axis=4 (i.e. energy)
[nlookup,count,ok,mess] = fread_catch(fid, 1, 'int32'); if ~all(ok); return; end;
offset_to_start = [0, 4*(nlookup + 6*nt), 2*(4*(nlookup + 6*nt)), 3*(4*(nlookup + 6*nt)) + 4*nlookup];   % offsets to beginning of blocks for each axis
offset_to_end = [4*(2*nlookup + 18*nt), 4*(nlookup + 12*nt), 4*(6*nt), 0];   % offsets from end of the axis data block to the end of the full data block
if iax<4
    [ind_lookup,count,ok,mess] = fread_catch(fid, [1,nlookup], 'int32'); if ~all(ok); return; end;
    ok = fseek (fid, offset_to_start(iax), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
    [v_lookup,count,ok,mess] = fread_catch(fid, [1,nlookup], 'float32'); if ~all(ok); return; end;
    lis = find(v_lookup>=vlo & v_lookup<=vhi);  % better way to find ilo, ihi using binary chop on v_lookup
    if ~isempty(lis)    % there are data points in the requested range
        ilo = ind_lookup(lis(1));
        ihi = ind_lookup(lis(end));
        ok = fseek (fid, 16*(ilo-1), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        [data.v,count,ok,mess] = fread_catch(fid, [4,(ihi-ilo+1)], 'float32'); if ~all(ok); return; end;
        ok = fseek (fid, 4*(4*(nt-ihi)+ilo-1), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        [data.S,count,ok,mess] = fread_catch(fid, [1,(ihi-ilo+1)], 'float32'); if ~all(ok); return; end;
        ok = fseek (fid, 4*((nt-ihi)+ilo-1), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        [data.ERR,count,ok,mess] = fread_catch(fid, [1,(ihi-ilo+1)], 'float32'); if ~all(ok); return; end;
        ok = fseek (fid, 4*((nt-ihi))+offset_to_end(iax), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
    else
        data.v = [];
        data.S = [];
        data.ERR = [];
        ok = fseek (fid, 4*(6*nt)+offset_to_end(iax), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
    end
else
    ok = fseek (fid, offset_to_start(iax), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
    lis = find(data.en>=vlo & data.en<=vhi);
    if ~isempty(lis)
        ilo = ndet*(lis(1)-1) + 1;
        ihi = ndet*lis(end);
        ok = fseek (fid, 16*(ilo-1), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        [data.v,count,ok,mess] = fread_catch(fid, [4,(ihi-ilo+1)], 'float32'); if ~all(ok); return; end;
        ok = fseek (fid, 4*(4*(nt-ihi)+ilo-1), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        [data.S,count,ok,mess] = fread_catch(fid, [1,(ihi-ilo+1)], 'float32'); if ~all(ok); return; end;
        ok = fseek (fid, 4*((nt-ihi)+ilo-1), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        [data.ERR,count,ok,mess] = fread_catch(fid, [1,(ihi-ilo+1)], 'float32'); if ~all(ok); return; end;
        ok = fseek (fid, 4*((nt-ihi))+offset_to_end(iax), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
    else
        data.v = [];
        data.S = [];
        data.ERR = [];
        ok = fseek (fid, 4*(6*nt)+offset_to_end(iax), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
    end
end
