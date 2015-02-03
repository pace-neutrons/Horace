function wout=mask_runs(win,runno)
%
% Routine to call mask_pixels of sqw object such that data from an entire
% contributing run are all masked, e.g. if one run from many in an sqw file
% is deemed to be spurious (e.g. detector noise, unknown sample
% orientation, etc.
%
% wout=mask_runs(win,runno)
%
% Input:    win     - sqw object to be masked (NB routine applies to single
%                     sqw objects only, not arrays.
%           runno   - run number, or array of run numbers, in data file to be
%                     masked. Convention is that run number 1 is the first file in the
%                     list when the sqw file was generated, and so on. Can be determined
%                     from inspection of win.header
%
% Output:   wout    - output sqw object with mask applied
%
% RAE 17/1/15; inspired by feedback from the Horace SNS roadshow 13-16/1/15
%

% Check object to be masked is an sqw-type object
if ~is_sqw_type(win);
    error('Can mask pixels only in an sqw-type object')
end

%Decree that we cannot work with arrays of sqw objects:
if numel(win)~=1
    error('mask_runs routine works only on single sqw objects, not arrays of objects');
end

% Initialise output argument
wout = win;
% Trivial case of empty or no mask arguments
if nargin==1 || isempty(runno)
    return
end

%Check runno is numeric:
if ~isnumeric(runno)
    error('Run number argument must be a numeric array');
end
if ~isvector(runno)
    error('Run number array must be scalar or vector');
end

%============
%

%Ensure that none of the elements of runno are not run numbers:
runs_present=[1:numel(win.header)];
if any(ismember(runno,runs_present)==0)
    error('One or more run numbers specified are outside the range of runs in the data');
end

%Do the masking calculation:
for i=1:numel(runno)
    mask_arr=ones(1,size(wout.data.pix,2));
    ff=find(wout.data.pix(5,:)==runno(i));
    mask_arr(ff)=0;
    wout=mask_pixels(wout,mask_arr);
end

