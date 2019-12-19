function [ok,mess,varargout] = parse_pixel_indicies (win,indx,iw)
% Return the indicies to pixels
%
% Check validity (sizes and extent of arrays, format of input arguments etc)
%   >> [ok,mess] = parse_pixel_indicies (win,indx)
%
% Get indicies for a particular sqw object
%   >> [ok,mess,irun,idet,ien] = parse_pixel_indicies (win)           % all pixels
%   >> [ok,mess,irun,idet,ien] = parse_pixel_indicies (win,indx)      % pixels in indx (if scalar)
%   >> [ok,mess,irun,idet,ien] = parse_pixel_indicies (win,indx,iw)   % Index in indx if not scalar
%
% Input:
% ------
% Checking validity:
%   win         Array of sqw objects, or cell array of scalar sqw objects
%
%   indx        Pixel indicies to be extracted fromt he sqw object(s)
%
%               Single sqw object:
%               ------------------
%                 - ipix            Column vector of pixels indicies
%            *OR* - irun_idet_ien   Array of run, detector and energy bin index
%                                  (array size nx3 where n is the number of pixels)
%
%               Multiple sqw objects:
%               ---------------------
%                 - As above: assumed to apply to all sqw objects,
%            *OR* - Cell array of the above, one cell array per sqw object
%                  e.g. if two sqw objects:
%                       {ipix1, ipix2}
%                       {irun_idet_ien_1, irun_idet_ien_2}
%
% [Optional]
%   iw          Indicies of the sqw objects in win into the indexing arrays
%              given by indx, one index for each for the sqw objects in win.
%               This can be used to fine tune the use of indx for a specific
%              sqw object or set of sqw objects without having to divide
%              up indx. If indx has only one entry, then it is assumed to
%              apply for any value of iw.
%
% Output:
% -------
%   ok          Status flag: =true if all ok, =false otherwise
%
%   mess        Error message: empty if ok, contains error message if not ok
%
%   irun        Single sqw object: Run indicies for each pixel (column vector)
%               Multiple sqw objects: Array of column vectors, one per object
%
%   idet        Single sqw object: Detector indicies for each pixel (column vector)
%               Multiple sqw objects: Array of column vectors, one per object
%
%   ien         Single sqw object: Energy bin indicies for each pixel (column vector)
%               Multiple sqw objects: Array of column vectors, one per object


nw = numel(win);
nout = nargout - 2;     % number of optional output arguments in series irun, idet, ien
if nw==0
    error('Function called with empty sqw argument')
end


% Case of only w as an input argument
% -----------------------------------
if nargin==1
    ok = true;
    mess = '';
    if nout>0
        if nw==1
            if iscell(win), pix = win{1}.data.pix; else, pix = win.data.pix; end
            if nout>=1, irun = pix(5,:)'; end   % column vector
            if nout>=2, idet = pix(6,:)'; end   % column vector
            if nout>=3, ien  = pix(7,:)'; end   % column vector
        else
            if nout>=1, irun = cell(size(win)); end
            if nout>=2, idet = cell(size(win)); end
            if nout>=3, ien  = cell(size(win)); end
            for i = 1:nw
                if iscell(win), pix = win{i}.data.pix; else, pix = win(i).data.pix; end
                if nout>=1, irun{i} = pix(5,:)'; end   % column vector
                if nout>=2, idet{i} = pix(6,:)'; end   % column vector
                if nout>=3, ien{i}  = pix(7,:)'; end   % column vector
            end
        end
        if nout>=1, varargout{1} = irun; end
        if nout>=2, varargout{2} = idet; end
        if nout>=3, varargout{3} = ien; end
    end
    return
end


% Case when given index array(s)
% ------------------------------
% Default return
ok = false;
mess = '';
if nout>0
    if nw==1
        if nout>=1, varargout{1} = zeros(0,1); end
        if nout>=2, varargout{2} = zeros(0,1); end
        if nout>=3, varargout{3} = zeros(0,1); end
    else
        if nout>=1, varargout{1} = repmat({zeros(0,1)},size(win)); end
        if nout>=2, varargout{2} = repmat({zeros(0,1)},size(win)); end
        if nout>=3, varargout{3} = repmat({zeros(0,1)},size(win)); end
    end
end

% Check iw, if given, is positive and consistent with the number of sqw objects
if exist('iw','var')
    if numel(iw)~=numel(win)
        mess = 'Number of indicies in index argument ''iw'' must equal the number of sqw objects';
        return
    elseif any(iw)<1
        mess = 'Indicies in index argument ''iw'' must be greater or equal to zero';
        return
    end
end

% Check indx
if isnumeric(indx)
    if ~(size(indx,2)==1 || size(indx,2)==3)
        mess = 'Indexing array must be a column vector or an nx3 array of run-detector-energy bin indicies';
        return
    end
    indx_internal = {indx};      % cell array for standard form later on
    iw_internal = ones(nw,1);    % every sqw object has the same indx array - indx is effectively infinitely long
    
elseif iscell(indx)
    nind = numel(indx);
    for i=1:nind
        if ~(isnumeric(indx{i}) && (size(indx(i),2)==1 || size(indx(i),2)==3))
            mess = 'Each indexing array must be a numeric column vector or an nx3 array of run-detector-energy bin indicies';
            return
        end
    end
    indx_internal = indx;        % standard name for internal working
    
    if nind==1
        iw_internal = ones(nw,1);    % every sqw object has the same indx array - indx is effectively infinitely long
    else
        if exist('iw','var')
            if all(iw)<=nind
                iw_internal = iw;
            else
                mess = ['Value(s) in the index argument ''iw'' must lie in the range 1 - ',num2str(nind)];
                return
            end
        else
            if nind==nw
                iw_internal = 1:nw;  % one indx array per sqw object
            else
                mess = 'If there is more than one indexing array, the number must match the number of sqw objects';
                return
            end
        end
    end
end

% Check consistency
for i=1:nw
    if iscell(win)
        wtmp = win{i};
    else
        wtmp = win(i);
    end
    indx_tmp = indx_internal{iw_internal(i)};
    if size(indx_tmp,2)==1
        if ~(max(indx_tmp)<=size(wtmp.data.pix,2) && min(indx_tmp)>=0)
            mess = 'One or more pixel indicies outside range of sqw object';
            return
        end
    else
        if iscell(wtmp.header)
            nrun = numel(wtmp.header);
            ne = cellfun(@(x)(numel(x.en)-1),wtmp.header);
        else
            nrun = 1;
            ne = numel(wtmp.header.en)-1;
        end
        ndet = numel(wtmp.detpar.x2);
        irun = indx_tmp(:,1);
        idet = indx_tmp(:,2);
        ien  = indx_tmp(:,3);
        if ~(max(irun)<=nrun && min(irun)>=0)
            mess = 'One or more run indicies outside range of sqw object';
            return
        elseif ~(max(idet)<=ndet && min(idet)>=0)
            mess = 'One or more detector indicies outside range of sqw object';
            return
        elseif ~(all(ien<=ne(irun)) && min(ien)>=0)
            mess = 'One or more energy bin indicies outside range of sqw object';
            return
        end
    end
end
ok = true;

% Fill output arrays if required
if nout>0
    if nw==1
        indx_tmp = indx_internal{iw_internal(1)};
        if size(indx_tmp,2)==1
            if iscell(win), pix = win{1}.data.pix; else, pix = win.data.pix; end
            if nout>=1, irun = pix(5,indx_tmp)'; end   % column vector
            if nout>=2, idet = pix(6,indx_tmp)'; end   % column vector
            if nout>=3, ien  = pix(7,indx_tmp)'; end   % column vector
        else
            if nout>=1, irun = indx_tmp(:,1); end
            if nout>=2, idet = indx_tmp(:,2); end
            if nout>=3, ien  = indx_tmp(:,3); end
        end
    else
        if nout>=1, irun = cell(size(win)); end
        if nout>=2, idet = cell(size(win)); end
        if nout>=3, ien  = cell(size(win)); end
        for i = 1:nw
            indx_tmp = indx_internal{iw_internal(i)};
            if size(indx_tmp,2)==1
                if iscell(win), pix = win{i}.data.pix; else, pix = win(i).data.pix; end
                if nout>=1, irun{i} = pix(5,indx_tmp)'; end   % column vector
                if nout>=2, idet{i} = pix(6,indx_tmp)'; end   % column vector
                if nout>=3, ien{i}  = pix(7,indx_tmp)'; end   % column vector
            else
                if nout>=1, irun{i} = indx_tmp(:,1); end
                if nout>=2, idet{i} = indx_tmp(:,2); end
                if nout>=3, ien{i}  = indx_tmp(:,3); end
            end
        end
    end
    if nout>=1, varargout{1} = irun; end
    if nout>=2, varargout{2} = idet; end
    if nout>=3, varargout{3} = ien; end
end
