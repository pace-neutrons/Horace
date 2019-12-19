function wout = func_eval (win, func_handle, pars, opt)
% Evaluate a function at the plotting bin centres of sqw object or array of sqw object
% Syntax:
%   >> wout = func_eval (win, func_handle, pars)
%   >> wout = func_eval (win, func_handle, pars, 'all')
%
% Input:
% ======
%   win         Dataset or array of datasets; the function will be evaluated
%              at the bin centres along the plot axes
%
%   func_handle Handle to the function to be evaluated at the bin centres
%               Must have form:
%                   y = my_function (x1,x2,... ,xn,pars)
%
%               or, more generally:
%                   y = my_function (x1,x2,... ,xn,pars,c1,c2,...)
%
%               - x1,x2,.xn Arrays of x coordinates along each of the n dimensions
%               - pars      Parameters needed by the function
%               - c1,c2,... Any further arguments needed by the function e.g.
%                          they could be the filenames of lookup tables for
%                          resolution effects)
%
%               e.g. y=gauss2d(x1,x2,[ht,x0,sig])
%                    y=gauss4d(x1,x2,x3,x4,[ht,x1_0,x2_0,x3_0,x4_0,sig1,sig2,sig3,sig4])
%
%   pars        Arguments needed by the function. 
%                - Most commonly just a numeric array of parameters
%                - If a more general set of parameters is needed by the function, then
%                  wrap as a cell array {pars, c1, c2, ...}
%
%   'all'       [option] Requests that the calculated function be returned over
%              the whole of the domain of the input dataset. If not given, then
%              the function will be returned only at those points of the dataset
%              that contain data.
%               Applies only to input with no pixel information - this option is ignored if
%              the input is a full sqw object.
%
% Output:
% =======
%   wout        Output objects or array of objects 
%
% e.g.
%   >> wout = func_eval (w, @gauss4d, [ht,x1_0,x2_0,x3_0,x4_0,sig1,sig2,sig3,sig4])
%
%   where the function gauss appears on the matlab path
%           function y = gauss4d (x1, x2, x3, x4, pars)
%           y = (pars(1)/(sig*sqrt(2*pi))) * ...

% NOTE:
%   If 'all' then npix=ones(size(win.data.s)) to ensure that the plotting is performed
%   Thus lose the npix information.

% Modified 15/10/2008 by R.A. Ewings:
% Modified the old d4d function to work with sqw objects of arbitrary
% dimensionality.
%
% Modified 09/11/2008 by T.G.Perring:
%  - Use nggridcell to make generic for dimensions greater than one
%  - Reinstate 'all' option
%  - Make output an sqw object with all pixels set equal to gid value. This is one
%    choice; another equally valid one is to say that the outut should be dnd object,
%    i.e. lose pixel information. The latter is a little counter to the spirit that if that is
%    what was intended, then shoucl have made a d1d,d2d,.. or whatever object before calling
%    func_eval
%       >>  wout = func_eval(dnd(win), func_handle, pars)
%    (note, if revert to latter, if array input then all objects must have same dimensionality)
%

% Check optional argument
if ~exist('opt','var')  % no option given
    all_bins=false;
elseif ischar(opt) && ~isempty(strmatch(lower(opt),'all'))    % option 'all' given
    all_bins=true;
else
    error('Unrecognised option')
end
    
wout = win;
if ~iscell(pars), pars={pars}; end  % package parameters as a cell for convenience

% Check if any objects are zero dimensional before evaluating fuction, to save on possible expensive computations
% before a 0D object is found in the array
for i = 1:numel(win)
    if isempty(win(i).data.pax)
        error('func_eval not supported for zero dimensional objects');
    end
end

% Evaluate function for each element of the array of sqw objects
for i = 1:numel(win)    % use numel so no assumptions made about shape of input array
    sqw_type=is_sqw_type(win(i));   % determine if sqw or dnd type
    ndim=length(win(i).data.pax);
    if sqw_type || ~all_bins        % only evaluate at the bins actually containing data
        ok=(win(i).data.npix~=0);   % should be faster than isfinite(1./win.data.npix), as we know that npix is zero or finite
    else
        ok=true(size(win(i).data.npix));
    end
    % Get bin centres
    pcent=cell(1,ndim);
    for n=1:ndim
        pcent{n}=0.5*(win(i).data.p{n}(1:end-1)+win(i).data.p{n}(2:end));
    end
    if ndim>1
        pcent=ndgridcell(pcent);%  make a mesh; cell array input and output
    end
    for n=1:ndim
        pcent{n}=pcent{n}(:);   % convert into column vectors
        pcent{n}=pcent{n}(ok);  % pick out only those bins at which to evaluate function
    end
    % Evaluate function
    wout(i).data.s(ok) = func_handle(pcent{:},pars{:});
    wout(i).data.e = zeros(size(win(i).data.e));

    % If sqw object, fill every pixel with the value of its corresponding bin
    if sqw_type
        s = replicate_array(wout(i).data.s, win(i).data.npix)';
        wout(i).data.pix(8:9,:) = [s;zeros(size(s))];
    elseif all_bins
        wout(i).data.npix=ones(size(wout(i).data.npix));    % in this case, must set npix>0 to be plotted.
    end
end
