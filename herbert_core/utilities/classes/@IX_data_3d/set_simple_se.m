function w = set_simple_se(w, s, e)
% Set signal and error fields in an IX_dataset_1d object with minimal checking of consistency - for fast setting. Use carefully!
%
%   >> w = set_simple_se(w, s, e)
%
%   s, e    Signal and error arrays - must be arrays with correct lengths along the x, y and z axes
%
% Only allows replacement signal and error arrays to have same size as current arrays i.e.
% cannot change between histogram and point mode for any of teh x, y and z axes.

sz_ref=size(w.signal);
if isnumeric(s) && numel(size(s))==numel(sz_ref) && all(size(s)==sz_ref) &&...
   isnumeric(e) && numel(size(e))==numel(sz_ref) && all(size(e)==sz_ref)    % catch obvious errors with sizes
    w.signal=s;
    w.error=e;
else
    error('Sizes of replacement signal and/or error array are inconsistent with current sizes')
end
