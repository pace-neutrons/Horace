function wout=sqw(win,sqwfunc,p,opt)
% Calculate sqw along the momentum plot axis of a 2D dataset
%
%   >> wout=sqw(win,sqwfunc,p)
%
%   win         Dataset that provides the axes and points for the calculation
%
%   sqwfunc     Handle to function that calculates S(Q,w)
%               Must have form:
%                   weight = sqwfunc (qh,qk,ql,en,p)
%                where
%                   qh,qk,ql,en Arrays containing the coordinates of a set of points
%                   p           Vector of parameters needed by dispersion function 
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                   weight      Array containing calculated energies; if more than
%                              one dispersion relation, then a cell array of arrays
%
%   p           Parameters to be passed to dispersion relation calculation above
%
%   'all'       [option] Requests that the calculated function be returned over
%              the whole of the domain of the input dataset. If not given, then
%              the function will be returned only at those points of the dataset
%              that contain data.
%
% Output:
% =======
%   wout        Output dataset or array of datasets 

% *** A superior algorithm would be only evaluate the function at the points where
% there is data - can avoid singularities. ***

wout=win;
for i=1:numel(win)
    qw = dnd_calculate_qw(get(win));
    wout(i).s = reshape(sqwfunc(qw{:},p),size(win(i).s));
    wout(i).e = zeros(size(win(i).s));
    if ~exist('opt','var')  % no option given
        % Do nothing
    elseif ischar(opt) && ~isempty(strmatch(lower(opt),'all'))    % option 'all' given
        index = isnan(wout(i).s);
        wout(i).s(index) = 0;
        wout(i).e(index) = 0;
    else
        error('Unrecognised option')
    end
end
