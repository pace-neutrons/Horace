function wout=sqw_eval(win, sqwfunc, pars, varargin)
% Calculate sqw for a model scattering function
%
%   >> wout=sqw_eval(win,sqwfunc,p)
%
% Input:
% ------
%   win        Dataset (or array of datasets) that provides the axes and points
%              for the calculation
%
%   sqwfunc     Handle to function that calculates S(Q,w)
%               Most commonly used form is:
%                   weight = sqwfunc (qh,qk,ql,en,p)
%                where
%                   qh,qk,ql,en Arrays containing the coordinates of a set of points
%                   p           Vector of parameters needed by dispersion function
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                   weight      Array containing calculated spectral weight
%
%               More general form is:
%                   weight = sqwfunc (qh,qk,ql,en,p,c1,c2,..)
%                 where
%                   p           Typically a vector of parameters that we might want
%                              to fit in a least-squares algorithm
%                   c1,c2,...   Other constant parameters e.g. file name for look-up
%                              table
%
%   pars       Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
% Optional string parameters:
%   'all'      Requests that the calculated sqw be returned over
%              the whole of the domain of the input dataset. If not given, then
%              the function will be returned only at those points of the dataset
%              that contain data_.
%               Applies only to input with no pixel information - it is ignored if
%              full sqw object.
%
%   'average' Requests that the calculated sqw be computed for the
%              average values of h,k,l of the pixels in a bin, not for each
%              pixel individually. Reduces cost of expensive calculations.
%              Applies only to the case of sqw object with pixel information
%             - it is ignored if dnd type object.
%
% Note: all optional string input parameters can be truncated up to minal
%       difference between them e.g. routine would accept 'al' and
%       'av', 'ave', 'aver' etc....
%
%
% Output:
% -------
%   wout        Output dataset or array of datasets


% Check optional argument
options = {'all', 'average'};
[ok, mess, all_bins, ave_pix] = parse_char_options(varargin, options);
if ~ok
    error('SQW_EVAL:invalid_argument',mess);
end

wout = copy(win);
if ~iscell(pars)  % package parameters as a cell for convenience
    pars = {pars};
end

for i=1:numel(wout)
   if has_pixels(wout(i))   % determine if object contains pixel data
       wout(i) = wout(i).sqw_eval_pix_(sqwfunc, ave_pix, pars);
   else
       wout(i) = wout(i).sqw_eval_nopix_(sqwfunc, all_bins, pars);
   end
end
