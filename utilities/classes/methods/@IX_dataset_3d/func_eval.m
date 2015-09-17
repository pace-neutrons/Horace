function wout = func_eval (w, func_handle, pars, opt)
% Evaluate a function over a dataset object or array of datasets.
% 
%   >> wout = func_eval (w, func_handle, pars)
%   >> wout = func_eval (w, func_handle, pars, 'all')
%
% Input:
% ------
%   w           Dataset or array of datasets
%
%   func_handle Handle to the function to be evaluated. Function must be of form
%                   val = my_func(x,y,z,arg1,arg2,arg3,...)
%               where x,y are the (x,y,z) coordinates of a set of points, and arg1, arg2,..
%               are the arguments of the function e.g.
%                   val=gauss3d(x,y,z,[ht,x0,y0,z0,sigx,sigy,sigy])
%                   val=my_func(x,y,z,[p1,p2,p3],symmetry_op,real_only)
%
%   pars        Arguments needed by the function. Most commonly, this will be 
%              a single argument that is a vector of parameter values :
%                   e.g. [height, centre, width]. 
%               If a more general set of parameters arg1, arg2,..., then package these
%              into a cell array and pass that as pars i.e. pars={arg1,arg2,arg3,...}
%                   e.g. {[p1,p2,p3],'invert',true}
%
%   'all'       [option] Requests that the calculated function be returned over
%              the whole of the domain of the input dataset. If not given, then
%              the function will be returned only at those points of the dataset
%              that contain data i,e, where signal~=NaN
%
% Output:
% -------
%   wout        Output objects or array of objects 
%
% e.g.
%   >> wout = func_eval (w, @gauss3d, [ht,x0,y0,z0,sigx,sigy,sigy])

% Check optional argument
if nargin<4                         % no option given
    all_bins=false;
elseif is_stringmatchi(opt,'all')    % option 'all' given
    all_bins=true;
else
    error('Unrecognised option')
end
    
wout=w;
if ~iscell(pars), pars={pars}; end  % package parameters as a cell for convenience

for i=1:numel(w)
    if (numel(w(i).x)~=size(w(i).signal,1))
        xtemp = 0.5*(w(i).x(1:end-1)+w(i).x(2:end));
    else
        xtemp = w(i).x;
    end
    if (numel(w(i).y)~=size(w(i).signal,2))
        ytemp = 0.5*(w(i).y(1:end-1)+w(i).y(2:end));
    else
        ytemp = w(i).y;
    end
    if (numel(size(w(i).signal))==2 && numel(w(i).z)~=1)||(numel(w(i).z)~=size(w(i).signal,3))   % could have singleton third dimension
        ztemp = 0.5*(w(i).z(1:end-1)+w(i).z(2:end));
    else
        ztemp = w(i).z;
    end
    [xtemp,ytemp,ztemp]=ndgrid(xtemp,ytemp,ztemp);
    data_shape  = size(w(i).signal);
    if all_bins
        wout(i).signal = reshape(func_handle(xtemp(:),ytemp(:),ztemp(:),pars{:}),data_shape);
    else
        ok=~isnan(w.signal);
        wout(i).signal(ok) = func_handle(xtemp(ok),ytemp(ok),ztemp(ok),pars{:});
    end
    wout(i).error = zeros(size(w(i).error));
end
