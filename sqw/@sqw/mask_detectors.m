function wout=mask_detectors(win,det_id)
% Remove all pixels from one or more detectors from an sqw object. Useful, for
% example if one detector was malfunctioning and needs to be masked from all
% runs that contributed to an sqw file.
%
%   >> wout = mask_runs (win, runno)
%
% Input:
% ------
%   win     sqw object to be masked (single object only, not array)
%   det_id  Detector ID, or array of detector IDs, in sqw object to be
%           masked. Information about which detector is which can be 
%           determined from inspection of win.detpar
%
% Output:
% -------
%   wout    Output sqw object with mask applied
%
% RAE - 9/5/2019
%


% Check object to be masked is an sqw-type object
if ~is_sqw_type(win);
    error('Can mask pixels only in an sqw-type object')
end

% Decree that we cannot work with arrays of sqw objects:
if numel(win)~=1
    error('mask_detectors routine works only on single sqw objects, not arrays of objects');
end

% Trivial case of empty or no mask arguments
if nargin==1 || isempty(det_id)
    wout=win;
    return
end

% Check det_id is numeric and in the range of runs in the data
if ~isnumeric(det_id)
    error('Detector ID argument must be a numeric array');
end
if ~isvector(det_id)
    error('Detector ID array must be scalar or vector');
end

ndet=numel(win.detpar.group);
if any(rem(det_id,1)~=0)
    error(['Run numbers to be masked must be integers in the range 1-',num2str(ndet)])
elseif min(det_id)<1 || max(det_id)>ndet
    error(['One or more detector ids specified are outside the range of detectors ids in the data (',num2str(ndet),')']);
end

% Do the masking calculation:
det_id=unique(det_id);    % remove duplicates if present
dets=win.data.pix(6,:);
mask_arr=true(size(dets));
for i=1:numel(det_id)
    mask_arr(dets==det_id(i))=false;
end
wout=mask_pixels(win,mask_arr);
