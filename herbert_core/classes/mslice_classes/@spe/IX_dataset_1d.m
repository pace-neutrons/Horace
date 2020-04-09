function wout = IX_dataset_1d (spe)
% Convert spe object into an array of IX_dataset_1d objects
%
%   >> wout=IX_dataset_1d(spe)
%
%   spe   	spe object
%
%   wout    Array of IX_dataset_1d object. Will be histogram object

tmp = IX_dataset_2d (spe);
wout= IX_dataset_1d (tmp);
