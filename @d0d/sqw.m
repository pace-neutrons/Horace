function wout=sqw(win,sqwfunc,p)
% Calculate sqw along the momentum plot axis of a 0D dataset
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
% Output
%   wout        Dataset containing calculated intensity

wout=win;
for i=1:numel(win)
    qw = dnd_calculate_qw(get(win));
    wout(i).s = reshape(sqwfunc(qw{:},p),size(win(i).s));
    wout(i).e=zeros(size(win(i).s));
    wout(i).n=ones(size(win(i).s));
end
