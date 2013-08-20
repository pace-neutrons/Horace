function wout=transform(w,xfunc,varargin)
% Transform the x-axis for an IX_dataset_1d object or array of IX_dataset_1d objects
%
%   >> wout = transform(w,xfunc,p1,p2,...)
%
% Input:
% ------
%   w       IX_dataset_1d object or array of IX_dataset_1d objects
%   xfunc   Handle to function that transforms the x-axis. Must have the form
%               xnew = myfunc(x)
%           Or if the function requires parameters (passed as described below)
%               xnew = another_func(x,p1,p2)
%           and the calls here would be e.g.
%               >> wout=transform(w,@myfunc)
%               >> wout=transform(w,@another_func,[0.02,1.5],'smooth')
%
%           The function can an anonumous function e.g.
%               >> fnc=@(x) x.^2;
%               >> wout=transform(w,fnc)
%
%   p1,p2.. [Optional] parameters needed by the transforming function
%
% Output:
% -------
%   wout    Output IX_dataset_1d object or array of IX_dataset_1d objects
%           with the x axis transformed according to the input function
%
% NOTE:
%   The signal and error values are unchanged i.e. the distribution flag is ignored.
%
%   If the function results in a non-monotonic set of x values, then if the
%  data is point data the x values are reordered to be monotonic increasing.
%  A non monotonic transformation is forbidden for histogram data.

hist=ishistogram(w);
opt_pars=~isempty(varargin);
wout=w;
for i=1:numel(w)
    if ~opt_pars
        xnew=xfunc(w(i).x);
    else
        xnew=xfunc(w(i).x,varargin{:});
    end
    dx=diff(xnew);
    if all(dx>0)
        wout(i).x=xnew;
    elseif all(dx<0)
        wout(i).x = fliplr(xnew);
        wout(i).signal = flipud(wout(i).signal);
        wout(i).error = flipud(wout(i).error);
    else
        if ~hist(i)
            [xnew,ix]=sort(xnew);
            wout(i).x=xnew;
            wout(i).signal=wout(i).signal(ix);
            wout(i).error=wout(i).error(ix);
        else
            error('Non-monotonic transformation of x-axis is fobidden for histogram data')
        end
    end
    
end
