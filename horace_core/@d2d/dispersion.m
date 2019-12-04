function [wdisp,weight]=dispersion(win,varargin)
% Calculate dispersion relation for dataset or array of datasets. 
%
% The output dataset (or array of data sets) will retain only the Q axes, and
% the signal array(s) will contain the values of energy along the Q axes.
%
% The dispersion relation is calculated at the bin centres. 
%
% If the function that calculates dispersion relations produces more than one
% branch, then in the case of a single input dataset the output will be an array
% of datasets, one for each branch. If the input is an array of datasets, then only
% the first dispersion branch will be returned, so there is one output dataset per
% input dataset.
%
%   >> wout=dispersion(win,dispreln,p)
%
% Input:
% ======
%   win         Dataset that provides the axes and points for the calculation
%               If one of the plot axes is energy transfer, then the output dataset
%              will have dimensionality one less than the input dataset
%
%   dispreln    Handle to function that calculates the dispersion relation w(Q)
%              Must have form:
%                   [w,s] = dispreln (qh,qk,ql,p)
%               where
%                   qh,qk,ql    Arrays containing the coordinates of a set of points
%                              in reciprocal lattice units
%                   p           Vector of parameters needed by dispersion function 
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                   w           Array of corresponding energies, or, if more than
%                              one dispersion relation, a cell array of arrays.
%                   s           Array of spectral weights, or, if more than
%                              one dispersion relation, a cell array of arrays.
%
%              More general form is:
%                   [w,s] = dispreln (qh,qk,ql,p,c1,c2,..)
%                 where
%                   p           Typically a vector of parameters that we might want 
%                              to fit in a least-squares algorithm
%                   c1,c2,...   Other constant parameters e.g. file name for look-up
%                              table.
%
%   p           Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
%
% Output:
% =======
%   wdisp       Output dataset or array of datasets. Output is always dnd-type.
%               The output dataset (or array of data sets) will retain only the Q axes, the
%              the signal array(s) will contain the values of energy along the Q axes, and
%              the error array will contain the square of the spectral weight.
%
%   weight      Mirror output: the signal is the spectral weight, and the error array
%               contains the square of the frequency.
%
%   e.g.        If win is a 2D dataset with Q and E axes, then wdisp is a 1D dataset
%              with just the Q axis


% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if nargout==1
    wdisp=dnd(dispersion(sqw(win),varargin{:}));
else
    [wdisp,weight]=dispersion(sqw(win),varargin{:});
    wdisp=dnd(wdisp);
    weight=dnd(weight);
end
