function status=ishistogram(w)
% Return array containing true or false depending on dataset being histogram or point
%
%   >> status=ishistogram(w)

status=true(size(w));
for iw=1:numel(w)
    if numel(w(iw).x)==numel(w(iw).signal)
        status(iw)=false;
    end
end
