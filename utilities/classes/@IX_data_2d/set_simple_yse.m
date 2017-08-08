function w = set_simple_yse(w, y, s, e)
% Set y, signal and error fields in an IX_dataset_2d object with minimal checking of consistency - for fast setting. Use carefully!
%
%   >> w = set_simple_yse(w, y, s, e)
%
%   y       y-axis array
%   s, e    Signal and error arrays - must be arrays with correct lengths along the x and y axes

if ~(isnumeric(y) && isvector(y))
    error('Replacement y-axis must be a vector')
elseif size(y,1)~=1
    y=y';   % if column vector, make row
end
if ~isnumeric(s) || ~isnumeric(e) || numel(size(s))~=2 || numel(size(e))~=2 || ~all(size(s)==size(e))
    error('Replacement signal and error arrays must be numeric arrays and have the same size')
end
if ~(size(s,1)==size(w.signal,1))
    error('Replacement signal array inconsistent with current x-axis')
end
if ~any(numel(y)-size(s,2)==[0,1])
    error('Replacement y axis and signal arrays must be consistent with one of histogram or point data along that axis')
end
w.y=y;
w.signal=s;
w.error=e;
