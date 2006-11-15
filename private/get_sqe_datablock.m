function [data, mess, lis, info] = get_sqe_datablock (fid, arg1, arg2)
%  Read the a block of data corresponding to one .spe file from a binary file created
% by gen_hkle.
%
% Syntax:
%   >> [data,mess] = get_sqe_datablock (fid)                % read to new data structure
%   >> [data,mess] = get_sqe_datablock (fid, axis)          % ...with control over read range
%   >> [data,mess] = get_sqe_datablock (fid, data_in)       % append to existing data structure
%   >> [data,mess] = get_sqe_datablock (fid, data_in, axis) % ...with control over read range
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
%                          [Note: there may additional pixels as well;
%                                 either or both of v_lo, v_hi can be infinite]
%              axis = 4x2 marix of values of limits along each of the four axes
%                   [vlo(1), vhi(1); vlo(2), vhi(2); vhi(3), vhi(3), vhi(4), vhi(4)]
%
% Output:
% -------
%   data        Data structure with the following fields:
%                 data.ei     Incident energy used for spe file (meV)
%                 data.psi    Psi angle (deg)
%                 data.cu     u crystal axis (r.l.u.) (see mslice) [row vector]
%                 data.cv     v crystal axis (r.l.u.) (see mslice) [row vector]
%                 data.file   File name of .spe file corresponding to the block being read
%                 data.size   size(1)=number of detectors; size(2)=number of energy bins [row vector]
%                 data.en     Vector containing the energy bin centres [row vector]
%                 data.v      Array containing the components along the projection
%                            axes u1, u2, u3, u4(==energy) for each pixel in the .spe file.
%                 data.S      Intensity vector [row vector]
%                 data.ERR    Variance vector [row vector]
%
%   mess        Error message; blank if all is OK, non-blank otherwise
%
%   lis         List of indices of data.v that have coordinates entirely within the
%              provided limits
%

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

                info.t_read = 0;
                info.t_lis  = 0;
                
% Check type of input arguments
if nargin==2 && isstruct(arg1)
    data = arg1;
elseif nargin==2 && (isa_size(arg1,[1,1],'double') | isa_size(arg1,[1,3],'double') | isa_size(arg1,[4,2],'double'))
    axis = arg1;
elseif nargin==3 && isstruct(arg1) && (isa_size(arg2,[1,1],'double') | isa_size(arg2,[1,3],'double') | isa_size(arg2,[4,2],'double'))
    data = arg1;
    axis = arg2;
elseif nargin~=1
    mess = 'ERROR: Check the input argument(s)';
    return
end

% Get axis and range to read (if possible without reading information from file)
if exist('axis','var')
    if ~(length(axis)==4)  % axis explicitly provided in call to function
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
        vlo = axis(:,1);
        vhi = axis(:,2);
    end
else
    iax = 4;   % default is energy axis
    vlo = -inf;
    vhi = inf;
end

% Read from file
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

% Now jump to relevant part of file depending on the axis given; if none then assume axis=4 (i.e. energy)
[nlookup,count,ok,mess] = fread_catch(fid, 1, 'int32'); if ~all(ok); return; end;

if ~exist('iax','var')    % haven't yet worked out which axis to read - will depend on the lookup aarrays for each axis
    [ind_lookup,count,ok,mess] = fread_catch(fid, [1,nlookup], 'int32'); if ~all(ok); return; end;
    ilo = zeros(1,4);
    ihi = zeros(1,4);
    for iax=1:3
        [v_lookup,count,ok,mess] = fread_catch(fid, [1,nlookup], 'float32'); if ~all(ok); return; end;
        lis = find(v_lookup>=vlo(iax) & v_lookup<=vhi(iax));  % [better way to find ilo, ihi must exist using binary chop on v_lookup]
        if ~isempty(lis)    % there are data points in the requested range
            ilo(iax) = ind_lookup(lis(1));
            ihi(iax) = ind_lookup(lis(end));
        else
            ilo(iax) = nan;
            ihi(iax) = nan;
        end
    end
    [data.en,count,ok,mess] = fread_catch(fid, [1,ne], 'float32'); if ~all(ok); return; end;
    lis = find(data.en>=vlo(4) & data.en<=vhi(4));
    if ~isempty(lis)
        ilo(4) = ndet*(lis(1)-1) + 1;
        ihi(4) = ndet*lis(end);
    else
        ilo(4) = nan;
        ihi(4) = nan;
    end
    ndat = ihi-ilo+1;
    if all(isfinite(ndat))  % there is data in the ranges for all axes
        [ndat_sort, iaxarr] = sort(ndat);
        iax = iaxarr(1);   % axis which requires shortest read
        % Goto start of block of data for axis iax:
        ok = fseek (fid, 4*((iax-1)*6*nt), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        ilo = ilo(iax);
        ihi = ihi(iax);
                t_ref = toc;
        ok = fseek (fid, 4*(4*(ilo-1)), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        [data.v,count,ok,mess] = fread_catch(fid, [4,(ihi-ilo+1)], 'float32'); if ~all(ok); return; end;
        ok = fseek (fid, 4*(4*(nt-ihi)+ilo-1), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        [data.S,count,ok,mess] = fread_catch(fid, [1,(ihi-ilo+1)], 'float32'); if ~all(ok); return; end;
        ok = fseek (fid, 4*((nt-ihi)+ilo-1), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        [data.ERR,count,ok,mess] = fread_catch(fid, [1,(ihi-ilo+1)], 'float32'); if ~all(ok); return; end;
        ok = fseek (fid, 4*((nt-ihi)+(4-iax)*6*nt), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
                info.t_read = toc - t_ref;
        if nargout>=3   % asked for list of pixels strictly in the requested range
%-------------------------------------------------------------
% Alternative code to this line follows:
                t_ref = toc;
            lis = find( data.v(1,:)>=vlo(1) & data.v(1,:)<=vhi(1) & data.v(2,:)>=vlo(2) & data.v(2,:)<=vhi(2) & ...
                        data.v(3,:)>=vlo(3) & data.v(3,:)<=vhi(3) & data.v(4,:)>=vlo(4) & data.v(4,:)<=vhi(4)  );
                info.t_lis = toc - t_ref;
%-------------------------------------------------------------
% Entirely equivalent code - but is no faster or even slower in practice
%             % Find exact index limits along read axis, and 
%             imin = lower_index(data.v(iaxarr(1),:),vlo(iaxarr(1)));
%             imax = upper_index(data.v(iaxarr(1),:),vhi(iaxarr(1)));
%             lis = imin:1:imax;
%             lis = lis(find(data.v(iaxarr(2),lis)>=vlo(iaxarr(2)) & data.v(iaxarr(2),lis)<=vhi(iaxarr(2))));
%             lis = lis(find(data.v(iaxarr(3),lis)>=vlo(iaxarr(3)) & data.v(iaxarr(3),lis)<=vhi(iaxarr(3))));
%             lis = lis(find(data.v(iaxarr(4),lis)>=vlo(iaxarr(4)) & data.v(iaxarr(4),lis)<=vhi(iaxarr(4))));
%-------------------------------------------------------------
        end
    else    % one or more of the axes ranges contains no data
        % Goto the end of the data block for this dataset
        ok = fseek (fid, 4*(24*nt), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        data.v = [];
        data.S = [];
        data.ERR = [];
        if nargout>=3; lis = []; end
    end
           
elseif iax<4
    [ind_lookup,count,ok,mess] = fread_catch(fid, [1,nlookup], 'int32'); if ~all(ok); return; end;
    % goto lookup block of axis iax, read in the lookup table and find which elements to read:
    ok = fseek (fid, 4*((iax-1)*nlookup), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end 
    [v_lookup,count,ok,mess] = fread_catch(fid, [1,nlookup], 'float32'); if ~all(ok); return; end;
    lis = find(v_lookup>=vlo & v_lookup<=vhi);  % [better way to find ilo, ihi must exist using binary chop on v_lookup]
    % Goto start of data block for energy bins, and read them in:
    ok = fseek (fid, 4*((3-iax)*nlookup), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
    [data.en,count,ok,mess] = fread_catch(fid, [1,ne], 'float32'); if ~all(ok); return; end;
    % Goto start of block of data for axis iax:
    ok = fseek (fid, 4*((iax-1)*6*nt), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
    % Find which elements to read from file and then read:
    if ~isempty(lis)    % there are data points in the requested range
        ilo = ind_lookup(lis(1));
        ihi = ind_lookup(lis(end));
        ok = fseek (fid, 4*(4*(ilo-1)), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        [data.v,count,ok,mess] = fread_catch(fid, [4,(ihi-ilo+1)], 'float32'); if ~all(ok); return; end;
        ok = fseek (fid, 4*(4*(nt-ihi)+ilo-1), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        [data.S,count,ok,mess] = fread_catch(fid, [1,(ihi-ilo+1)], 'float32'); if ~all(ok); return; end;
        ok = fseek (fid, 4*((nt-ihi)+ilo-1), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        [data.ERR,count,ok,mess] = fread_catch(fid, [1,(ihi-ilo+1)], 'float32'); if ~all(ok); return; end;
        ok = fseek (fid, 4*((nt-ihi)+(4-iax)*6*nt), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        if nargout>=3   % asked for list of pixels strictly in the requested range
            lis = find( data.v(iax,:)>=vlo & data.v(iax,:)<=vhi);
        end
    else
        data.v = [];
        data.S = [];
        data.ERR = [];
        if nargout>=3; lis = []; end
        ok = fseek (fid, 4*((5-iax)*6*nt), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
    end
    
elseif iax==4
    % skip over index array and lookup arrays for axes 1,2,3:
    ok = fseek (fid, 4*(4*nlookup), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
    % Read energy bins
    [data.en,count,ok,mess] = fread_catch(fid, [1,ne], 'float32'); if ~all(ok); return; end;
    lis = find(data.en>=vlo & data.en<=vhi);
    % Goto start of block of data for energy axis:
    ok = fseek (fid, 4*(3*6*nt), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
    if ~isempty(lis)
        ilo = ndet*(lis(1)-1) + 1;
        ihi = ndet*lis(end);
        ok = fseek (fid, 4*(4*(ilo-1)), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        [data.v,count,ok,mess] = fread_catch(fid, [4,(ihi-ilo+1)], 'float32'); if ~all(ok); return; end;
        ok = fseek (fid, 4*(4*(nt-ihi)+ilo-1), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        [data.S,count,ok,mess] = fread_catch(fid, [1,(ihi-ilo+1)], 'float32'); if ~all(ok); return; end;
        ok = fseek (fid, 4*((nt-ihi)+ilo-1), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        [data.ERR,count,ok,mess] = fread_catch(fid, [1,(ihi-ilo+1)], 'float32'); if ~all(ok); return; end;
        ok = fseek (fid, 4*(nt-ihi), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
        lis = ones(1,ihi-ilo+1);    % all data points are in the requested energy range
    else
        data.v = [];
        data.S = [];
        data.ERR = [];
        if nargout>=3; lis = []; end
        ok = fseek (fid, 4*(6*nt), 'cof'); if ok~=0; mess = 'Unable to jump to required location in file'; return; end
    end
end
