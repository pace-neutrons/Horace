function status=ishistogram(w,n)
% Return array containing true or false depending on dataset being histogram or point
%
%   >> status=ishistogram(w)    % array [2,size(w)] with true for each of the two axes
%   >> status=ishistogram(w,n)  % array size of w for the nth axis, n=1 or 2

% Check axis index
if nargin>1
    % Just one axis being tested
    if ~(isnumeric(n) && isscalar(n) && (n==1||n==2))
        error('Check axis index = 1 or 2')
    end
    status=true(size(w));
    if n==1
        for iw=1:numel(w)
            if numel(w(iw).x)==size(w(iw).signal,1)
                status(iw)=false;
            end
        end
    else
        for iw=1:numel(w)
            if numel(w(iw).y)==size(w(iw).signal,2)
                status(iw)=false;
            end
        end
    end
    
else
    % Both axes being tested
    status=true([2,size(w)]);
    for iw=1:numel(w)
        if numel(w(iw).x)==size(w(iw).signal,1)
            status(1,iw)=false;
        end
        if numel(w(iw).y)==size(w(iw).signal,2)
            status(2,iw)=false;
        end
    end

end
