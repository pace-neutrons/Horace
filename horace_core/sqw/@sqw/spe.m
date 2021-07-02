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
    error('Input sqw object does not have sqw type (i.e. does not contain pixel information')
end

if iscell(w.header_x)
    error('sqw object has contributions from more than one spe file')
end

% Get file name and path from sqw object
data.filename=w.header_x.filename;
data.filepath=w.header_x.filepath;

% Extract signal and error
ne=numel(w.header_x.en)-1;    % number of energy bins
ndet0=numel(w.detpar.group);% number of detectors

tmp=w.data.pix.get_data({'detector_idx', 'energy_idx', 'signal', 'variance'})';
tmp=sortrows(tmp,[1,2]);    % order by detector group number, then energy
group=unique(tmp(:,1));    % unique detector group numbers in the data in numerical increasing order

% Now check that the data is complete i.e. no missing pixels
if size(tmp,1)~=ne*numel(group)
    error('Data for one or more energy bins is missing in the sqw data')
end

% Get the indexing of detector group in the detector information
[lia,ind]=ismember(group,w.detpar.group);

signal=NaN(ne,ndet0);
err=zeros(ne,ndet0);
signal(:,ind)=reshape(tmp(:,3),ne,numel(group));
err(:,ind)=sqrt(reshape(tmp(:,4),ne,numel(group)));
data.S=signal;
data.ERR=err;

% Get energy bin boundaries
data.en=w.header_x.en;

% Create output object
d=spe(data);
