function status=ishistogram(w,n)
% Return array containing true or false depending on dataset being histogram or point
%
%   >> status=ishistogram(w)    % array size(w) with true/false for the axis
%   >> status=ishistogram(w,1)  % same as above; syntax for compatibility with IX_dataset_2d, IX_dataset_3d,...

% For compatibility with general dimensionality
if nargin>1
    if ~(isnumeric(n) && isscalar(n) && n==1)
        error('Check axis index = 1')
    end
end

% Return status
status=true(size(w));
for iw=1:numel(w)
    if numel(w(iw).x)==numel(w(iw).signal)
        status(iw)=false;
    end
end
