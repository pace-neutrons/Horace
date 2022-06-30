function wout=unpack(w)
% Create an array of IX_dataset_2d, one element per y value, from the input IX_dataset_2d.
%
%   >> wout=unpack(w,ind)
%
% Input:
% ------
%   w       IX_dataset_2d object or array of IX_dataset_2d objects
%
% Output:
% -------
%   wout    Array of IX_dataset_2d objects, one per y value, and retaining the 
%           y values corresponding to the first numel(ind) y values

% Return if empty object
if numel(w)==0
    wout=w;
    return
end

% Get array of number of spectra in each element of w
ns=zeros(1,numel(w));
for i=1:numel(w)
    [dummy,sz]=dimensions(w(i));
    ns(i)=sz(2);
end
nsend=cumsum(ns);
nsbeg=[1,nsend(1:end-1)+1];
nstot=nsend(end);

% Catch case of all empty
if nstot==0
    if numel(w)==1
        wout=w;     % just one empty input, so return this
        return
    else
        % empty objects need not have the same number of x-values, so unpack is meaningless for an array
        error('Input object is array of empty objects - unpack not possible')
    end
end

% Unpack each object
wout=repmat(IX_dataset_2d,[nstot,1]);
for i=1:numel(w)
    if ns(i)>0
        wout(nsbeg(i):nsend(i))=unpack_single(w(i));
    end
end

%--------------------------------------------------------------------------------------------------
function wout=unpack_single(w)
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
