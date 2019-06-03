function varargout=get_mod_pulse_horace(varargin)
% Get moderator pulse model name and mean pulse parameters in a file or set of Horace data files
%
%   >> [pulse_model,pp,ok,mess,p] = get_mod_pulse_horace (win)
%   >> [pulse_model,pp,ok,mess,p] = get_mod_pulse_horace (win,tol)
%
% Input:
% ------
%   file        File name, or cell array of file names. In latter case, the
%              change is performed on each file
%   tol         [Optional] acceptable relative spread w.r.t. average of moderator
%              pulse shape parameters: maximum over all parameters of
%                   max(|max(p)-p_ave|,|min(p)-p_ave|) <= tol
%
% Output:
% -------
%   pulse_model Name of moderator pulse shape model e.g. 'ikcarp'
%              Must be the same for all data sets in all sqw objects (returned
%              as '' if not all the same)
%   pp          Mean moderator pulse shape parameters (numeric row vector)
%             (Returned as [] if not all the same pulse model or length of
%              pulse parmaeters array not all the same)
%   ok          Logical flag: =true if all parameters within tolerance, otherwise =false;
%   mess        Error message; empty if OK, non-empty otherwise
%   p           Structure with various information about the spread
%                   p.pp       array of all parameter values, one row per data set
%                   p.ave      average parameter values (row vector)
%                             (same as output argument pp)
%                   p.min      minimum parameter values (row vector)
%                   p.max      maximum parameter values (row vector)
%                   p.relerr   larger of (max(p)-p_ave)/p_ave
%                               and abs((min(p)-p_ave))/p_ave
%                 (If pulse model or not all the same, or number of parameters
%                  not the same for all data sets, ave,min,max,relerr all==[])


% Original author: T.G.Perring
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)


if nargin<1 ||nargin>2
    error('Check number of input arguments')
elseif nargout>6
    error('Check the number of output arguments')
end

[varargout,mess] = horace_function_call_method (nargout, @get_mod_pulse, '$hor', varargin{:});
if ~isempty(mess), error(mess), end
