function wout=unpack(w)
% Create an array of IX_dataset_2d, one element per y value, from a larger IX_dataset_2d object
%
%   >> wout=unpack(w,ind)
%
% Input:
% ------
%   w       IX_dataset_2d object
%
% Output:
% -------
%   wout    Array of IX_dataset_2d objects, one per y value, and retaining the 
%           y values corresponding to the first numel(ind) y values

if numel(w)~=1
    error('Function only takes a single IX_dataset_2d object, not an array of IX_dataset_2d objects')
end

[dummy,sz]=dimensions(w);
nd=sz(1); ns=sz(2);
yhist=ishistogram(w,2);
if yhist, ydummy=[0,1]; else ydummy=0; end  % dummy y array of correct length
wtmp=IX_dataset_2d(w.title,zeros(nd,1),zeros(nd,1),w.s_axis,w.x,w.x_axis,w.x_distribution,ydummy,w.y_axis,w.y_distribution);
wout=repmat(wtmp,ns,1);

y=w.y;
signal=w.signal;
err=w.error;
for i=1:ns
    wout(i).signal=signal(:,i);
    wout(i).error=err(:,i);
    if yhist
        wout(i).y=y(i:i+1);
    else
        wout(i).y=y(i);
    end
end
