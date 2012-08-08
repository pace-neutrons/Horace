function wout=subset(w,ind)
% Extract a subset of the data in an IX_dataset_2d object defined by the indicies along the y-axis
%
%   >> wout=subset(w,ind)
%
% Input:
% ------
%   w       IX_dataset_2d object
%   ind     Array of indicies on the y-axis to extract, taken from 1,2,3...ny
%           where ny is the length of the y-axis
% Output:
% -------
%   wout    IX_dataset_2d object, with the extracted signal, and retaining the 
%           y values corresponding to the first numel(ind) y values

wout=w;
[dummy,sz]=dimensions(w);
if isempty(ind) || min(ind)<1 || max(ind)>sz(2) || any(diff(ind(:))<1)
    error(['Check range of indicies is increasing and is within the range 1-',num2str(sz(2))])
end
if sz(2)==numel(w.y)    % point data
    wout.y=w.y(1:numel(ind));
else
    wout.y=w.y(1:numel(ind)+1);
end
wout.signal=w.signal(:,ind);
wout.error=w.error(:,ind);
