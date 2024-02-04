function d=spe(w)
% Convert sqw object to spe data, if possible.
%
%   >> d = spe(w)
%
% Conversion is possible only if the sqw object was made from a single spe
% file and that it contains all the data from the spe file. The second
% condition means that the sqw object must contain the pixel informationno cut has been performed that contains all the pixel following is true:
%               - The sqw object is sqw-type
%               - Only one spe file contributed
%               - All energy bins for a given detector are either
%                present or absent. That is, the sqw file contains all
%                pixels for a detector, or the detector was completely
%                masked.
%
% Input:
% ------
%   w       sqw object
%
% Output:
% -------
%   d       spe data object. Fields are:
%               filename   Name of file excluding path
%               filepath   Path to file including terminating file separator
%               S          [ne x ndet] array of signal values
%               ERR        [ne x ndet] array of error values (st. dev.)
%               en         Column vector of energy bin boundaries

if ~has_pixels(w)
    error('HORACE:sqw:invalid_argument', ...
        'Input sqw object does not have sqw type (i.e. does not contain pixel information')
end

if iscell(w.experiment_info)
    error('HORACE:sqw:invalid_argument', ...
        'sqw object has contributions from more than one spe file')
end

% Get file name and path from sqw object
if isa(w.experiment_info,'Experiment')
    data.filename=w.experiment_info.expdata(1).filename;
    data.filepath=w.experiment_info.expdata(1).filepath;
else
    data.filename=w.experiment_info.filename;
    data.filepath=w.experiment_info.filepath;
end

% Extract signal and error
if isa(w.experiment_info,'Experiment')
    ne=numel(w.experiment_info.expdata(1).en)-1;    % number of energy bins
else
    ne=numel(w.experiment_info.en)-1;    % number of energy bins
end
ndet0=numel(w.detpar.group);% number of detectors
didx = w.pix.detector_idx;
eidx = w.pix.energy_idx;
sv   = w.pix.sig_var;
tmp  = [didx;eidx;sv]';

tmp=sortrows(tmp,[1,2]);   % order by detector group number, then energy
group=unique(tmp(:,1));    % unique detector group numbers in the data in numerical increasing order

% Now check that the data is complete i.e. no missing pixels
if size(tmp,1)~=ne*numel(group)
    error('Data for one or more energy bins is missing in the sqw data')
end

% Get the indexing of detector group in the detector information
[~,ind]=ismember(group,w.detpar.group);

signal=NaN(ne,ndet0);
err=zeros(ne,ndet0);
signal(:,ind)=reshape(tmp(:,3),ne,numel(group));
err(:,ind)=sqrt(reshape(tmp(:,4),ne,numel(group)));
data.S=signal;
data.ERR=err;

% Get energy bin boundaries
if isa(w.experiment_info,'Experiment')
    data.en=w.experiment_info.expdata(1).en;
else
    data.en=w.experiment_info.en;
end

% Create output object
d=spe(data);
