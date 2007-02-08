function wout=sqw(win,sqwfunc,p)
% Calculate sqw along the momentum plot axis of a 3D dataset
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
wout.s=dnd_sqw(get(win),sqwfunc,p);
wout.e=zeros(size(wout.s));
wout.n=ones(size(wout.s));
