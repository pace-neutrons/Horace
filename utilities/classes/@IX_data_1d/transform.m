function wout=transform(w,xfunc,pars)
% Transform the x-axis for an IX_dataset_1d object or array of IX_dataset_1d objects
%
%   >> wout = transform(w,xfunc,pars)
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
%   The signal and error values are unchanged i.e. the distribution flag is ignored.
%
%   If the function results in a non-monotonic set of x values, then if the
%  data is point data the x values are reordered to be monotonic increasing.
%  A non monotonic transformation is forbidden for histogram data.

if nargin==2
    opt_pars=false;
else
    opt_pars=true;
end
hist=ishistogram(w);
wout=w;
for i=1:numel(w)
    if ~opt_pars
        xnew=xfunc(w(i).x);
    else
        if ~iscell(pars)
            xnew=xfunc(w(i).x,pars);
        else
            xnew=xfunc(w(i).x,pars{:});
        end
    end
    xnew=reshape(xnew,size(w(i).x));     % ensure same shape of x array - user fucntion may do weird things
    dxnew=diff(xnew);
    if all(dxnew>0)
        wout(i).x=xnew;
    elseif all(dxnew<0)
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
            error('Non-monotonic transformation of x-axis is forbidden for histogram data')
        end
    end
    
end
