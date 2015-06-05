function wout=mask_runs(win,runno)
% Remove all pixels from one or more runs from an sqw object. Useful, for
% example if one run from many in an sqw file is deemed to be spurious (e.g.
% detector noise, unknown sample orientation, etc.)
%
%   >> wout = mask_runs (win, runno)
%
% Input:
% ------
%   win     sqw object to be masked (single object only, not array)
%   runno   Run number, or array of run numbers, in sqw object to be
%           masked. Convention is that run number 1 is the first file in the
%           list when the sqw file was generated, and so on. Can be determined
%           from inspection of win.header
%
% Output:
% -------
%   wout    Output sqw object with mask applied


% Original author: R.A.Ewings
%
% $Revision$ ($Date$)


% Check object to be masked is an sqw-type object
if ~is_sqw_type(win);
    error('Can mask pixels only in an sqw-type object')
end

% Decree that we cannot work with arrays of sqw objects:
if numel(win)~=1
    error('mask_runs routine works only on single sqw objects, not arrays of objects');
end

% Trivial case of empty or no mask arguments
if nargin==1 || isempty(runno)
    wout=win;
    return
end

% Check runno is numeric and in the range of runs in the data
if ~isnumeric(runno)
    error('Run number argument must be a numeric array');
end
if ~isvector(runno)
    error('Run number array must be scalar or vector');
end

nrun=numel(win.header);
if any(rem(runno,1)~=0)
    error(['Run numbers to be masked must be integers in the range 1-',num2str(nrun)])
elseif min(runno)<1 || max(runno)>nrun
    error(['One or more run numbers specified are outside the range of runs in the data (',num2str(nrun),')']);
end

% Do the masking calculation:
runno=unique(runno);    % remove duplicates if present
runs=win.data.pix(5,:);
mask_arr=true(size(runs));
for i=1:numel(runno)
    mask_arr(runs==runno(i))=false;
end
wout=mask_pixels(win,mask_arr);
