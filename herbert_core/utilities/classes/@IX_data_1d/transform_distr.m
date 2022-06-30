function wout=transform_distr(w,xfunc,pars)
% Transform the x-axis for an IX_dataset_1d histogram distribution or array of the same
%
%   >> wout = transform_dist(w,xfunc,pars)
%
% Input:
% ------
%   w       IX_dataset_1d object or array of IX_dataset_1d objects
%   xfunc   Handle to function that transforms the x-axis. Must have the form:
%               xnew = myfunc(x)
%             or (if the function requires parameters, passed as described below)
%               xnew = another_func(x,p1,p2)
%
%           The calls here would be e.g.
%               >> wout=transform(w,@myfunc)
%               >> wout=transform(w,@another_func,{[0.02,1.5],'smooth'})
%
%           The function can an anonumous function e.g.
%               >> fnc=@(x) x.^2;
%               >> wout=transform(w,fnc)
%
%   pars    [Optional] parameters needed by the transforming function
%           If the transformation function requires more than one parameter
%           then put them all in a cell array, as in the example above.
%
% Output:
% -------
%   wout    Output IX_dataset_1d object or array of IX_dataset_1d objects
%           with the x axis transformed according to the input function
%
% NOTE:
%   Only works on distribution data.
%   The signal and error values are changed accordingly

if nargin==2
    opt_pars=false;
else
    opt_pars=true;
end
hist=ishistogram(w);
wout=w;

dist=false(size(w));
for i=1:numel(w)
    dist=w(i).x_distribution;
end
if ~all(dist(:))
    error('The data set(s) must all be distribution data for this operation')
end

for i=1:numel(w)
    % Convert to histogram data if required
    if hist(i)
        wtmp=w(i);
    else
        wtmp=point2hist(w(i));
    end
    % Transform x-axis at bin boundaries
    if ~opt_pars
        xnew=xfunc(wtmp.x);
    else
        if ~iscell(pars)
            xnew=xfunc(wtmp.x,pars);
        else
            xnew=xfunc(wtmp.x,pars{:});
        end
    end
    xnew=reshape(xnew,size(wtmp.x));     % ensure same shape of x array - user function may do weird things
    dx=diff(wtmp.x);
    dxnew=diff(xnew);
    % Perform Jacobian transformation
    invjac=abs(dx./dxnew);
    wout(i).signal = (wout(i).signal).*invjac';
    wout(i).error = (wout(i).error).*invjac';
    % Compute x-axis at points if point data
    if ~hist(i)
        if ~opt_pars
            xnew=xfunc(w(i).x);
        else
            if ~iscell(pars)
                xnew=xfunc(w(i).x,pars);
            else
                xnew=xfunc(w(i).x,pars{:});
            end
        end
        xnew=reshape(xnew,size(w(i).x));     % ensure same shape of x array - user function may do weird things
    end
    % Fill x-axis
    if all(dxnew>0)
        wout(i).x=xnew;
    elseif all(dxnew<0)
        wout(i).x = fliplr(xnew);
        wout(i).signal = flipud(wout(i).signal);
        wout(i).error = flipud(wout(i).error);
    else
        error('Non-monotonic transformation of x-axis is forbidden for histogram data')
    end
    
end
