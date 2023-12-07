function [irun, idet, ien] = parse_pixel_indices (win, varargin)
% Return the run, detector and energy indices of pixels in one or more sqw objects
%
%   >> [irun, idet, ien] = parse_pixel_indices (win)        % all pixels
%   >> [irun, idet, ien] = parse_pixel_indices (win, ipix)  % selected pixels
%
% Note: an efficient way of checking that ipix is consistent with all the sqw
% objects is to call without output arguments i.e.
%
%   >> parse_pixel_indices (win, ipix)
%
% This will return silently without without spending time computing output
% argument irun if the arguments are consistent, but will throw an error with an
% appropriate message if e.g. ipix is out of range for
%
%
% Input:
% ------
% Checking validity:
%   win         Array of sqw objects, or cell array of scalar sqw objects
%
% [Optional]
%   ipix        Pixel indices for which the output is to be extracted from the
%               sqw object(s)
%
%               - Array of pixel indices. If there are multiple sqw objects,
%                 it is then applied to every sqw object
%
%               - Cell array of pixel indices arrays
%                   - only one array: applied to every sqw object, or
%                   - several pixel indices arrays: one per sqw object
%
% Output:
% -------
%   irun        Single sqw object: Array of indices into the experiment_info
%                                  In a cell array if the sqw object was in a cell
%               Multiple sqw objects: Cell array of arrays, one per sqw object
%                                  Cell array has the same size as win
%
%   idet        Single sqw object: Array of detector indices for the pixels
%                                  In a cell array if the sqw object was in a cell
%               Multiple sqw objects: Cell array of arrays, one per sqw object
%                                  Cell array has the same size as win
%
%   ien         Single sqw object: Energy bin indices for each pixel (column vector)
%                                  In a cell array if the sqw object was in a cell
%               Multiple sqw objects: Cell array of arrays, one per sqw object
%                                  Cell array has the same size as win
%
% For each of irun, idet and ien, note that:
% - If ipix was not given, the output arrays for each sqw object are column vectors
% - If ipix was given, the output arrays for each sqw object have the same shape
%   as the corresponding array indices array within ipix


% Ensure sqw objects form a cell array of scalar sqw object(s)
% (The case of being an sqw object array will have been caught already by the
% sqw method with the same name, according as the Matlab calling hierarchy)
if ~iscell(win) || isempty(win) || ~all(cellfun(@(x)(isa(x,'sqw') && isscalar(x)), win))
    error('HORACE:parse_pixel_indices:invalid_argument', ['The argument ''win''',...
        'must an array of sqw objects or a cell array of scalar sqw objects'])
end

% Convert input into array of sqw objects and call sqw method on the array
win_as_sqw_array = reshape([win{:}], size(win));
[irun, idet, ien] = parse_pixel_indices (win_as_sqw_array, varargin{:});

% If win was a cell array with just a scalar sqw object, then put the output in
% cell arrays as well for consistency of packaging
if numel(win) == 1
    irun = {irun};
    idet = {idet};
    ien = {ien};
end

end
