function wout = mask (win, mask_array)
% Remove the data points indicated by the mask array
%
%   >> wout = mask (win, mask_array)
%
% Input:
% ------
%   win                 Input dataset
%   mask_array          Array of 1 or 0 (or true or false) that indicate
%                      which points to retain (true to retain, false to ignore)
%                       Numeric or logical array with same number of elements
%                      as the data.
% Output:
% -------
%   wout                Output dataset. Masked points have signal and error set to NaN.

% This function is independent of the dimensionality of the IX_dataset_nd object

% Initialise output argument
wout = win;

% Trivial case of empty or no mask arguments
if nargin==1 || isempty(mask_array)
    return
end

% Check mask is OK
if ~(isnumeric(mask_array) || islogical(mask_array)) || numel(mask_array)~=numel(win.signal)
    error('IX_dataset_1d:invalid_argument',...
        'Mask must provide a numeric or logical array with same number of elements as the data')
end
if ~islogical(mask_array)
    mask_array=logical(mask_array);
end

% Mask signal and error arrays
wout.signal(~mask_array) = NaN;
wout.error(~mask_array) = NaN;
