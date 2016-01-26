function weight = disp2sqw(varargin)
% Calculate spectral weight given dispersion relation and spectral weight
%
%   >> weight = disp2sqw(qh,qk,ql,en,dispreln,pars,fwhh)
%   >> weight = disp2sqw(q,en,dispreln,pars,fwhh)
%
% Input:
% ------
%   qh,qk,ql,en Arrays containing points at which to evaluate sqw from the
%              broadened dispersion
%     *OR*
%   q           Cell array of three arrays {qh,qk,ql} at which to evaluate
%              the dispersion
%
%   en          Array of energy transfers at which the broadened dispersion
%              is evaluate for every q
%
%   dispreln    Handle to function that calculates the dispersion relation
%              or set of dispersion relations w(Q) and corresponding spectral
%              weight, s(Q)
%               Must have the form:
%                   [w,s] = dispreln (qh,qk,ql,p)
%               where
%                 Input:
%                   qh,qk,ql    Arrays containing the coordinates of a set
%                              of points in reciprocal lattice units
%                   p           Vector of parameters needed by the function
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                 Output:
%                   w           Array of corresponding energies, or, if more than
%                              one dispersion relation, a cell array of arrays.
%                   s           Array of spectral weights, or, if more than
%                              one dispersion relation, a cell array of arrays.
%
%              More general form is:
%                   [w,s] = dispreln (qh,qk,ql,p,c1,c2,..)
%                 where
%                   p           Typically a vector of parameters that we might
%                              want to fit in a least-squares algorithm
%                   c1,c2,...   Other constant parameters e.g. file name of
%                              a look-up table.
%
%   pars        Arguments needed by the function.
%               - Most commonly, a vector of parameter values e.g. [A,js,gam]
%                 as intensity, exchange, lifetime.
%               - More generally, if addition constant arguments are needed
%                 by the dispersion function, then package these into a cell
%                 array and pass that as pars. In the example above then
%                 pars = {p, c1, c2, ...}
%
%   fwhh        Parametrizes the resolution function. There are three
%               possible input values of fwhh:
%
%       double              A single FWHM value determines the FWHM of the 
%                           Gaussian resolution function
%       function_handle     A function that produces the FWHM value as a
%                           function of energy transfer, it has to have the
%                           following simple header (where omega can be a row
%                           vector of energies:
%                               dE = resfun(omega)
%       function_handle     A function handle of a function with two input
%                           parameters with the following header:
%                               I = shapefun(Emat,omega)
%                           where Emat is a matrix with dimensions of [nQ nE]
%                           and omega is a column vector with nQ elements. The
%                           shapefun produces a peakshape for every Q point
%                           centered at the given omega and normalized to one.
%                           The output I has the same dimensions as the
%                           input Emat.
% Output:
% -------
%   weight      Array with spectral weight at the q,e points
%               If q and en given:  weight is an nq x ne array, where nq
%                                   is the number of q points, and ne the
%                                   number of energy points
%               If qw given together: weight has the same size and dimensions
%                                     as q{1} i.e. qh


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Parse input arguments
if nargin==7
    expand_qe=false;    % set of distinct q points
    q=varargin(1:3);
    en=varargin{4};
    dispreln=varargin{5};
    pars=varargin{6};
    fwhh=varargin{7};
elseif nargin==5
    expand_qe=true;     % same q array for each energy in the energy array
    q=varargin{1};
    en=varargin{2};
    dispreln=varargin{3};
    pars=varargin{4};
    fwhh=varargin{5};
elseif nargin==4
    expand_qe=false;
    q=varargin{1}(1:3);
    en=varargin{1}{4};
    dispreln=varargin{2};
    pars=varargin{3};
    fwhh=varargin{4};
else
    error('Check number of input arguments')
end

% Evaluate dispersion relation(s)
if ~iscell(pars), pars={pars}; end      % package parameters as a cell for convenience

if nargout(dispreln)==1
    e=dispreln(q{:},pars{:});   % only dispersion seems to be provided
    if ~iscell(e)   % convert to cell array for convenience
        e={e};
    end
    sf=cell(size(e));
    for ii=1:numel(e)
        sf{ii}=ones(size(e{ii}));
    end
else
    [e,sf]=dispreln(q{:},pars{:});
    if ~iscell(e)   % convert to cell array for convenience
        e={e};
        sf={sf};
    end
end

% resolution function definintion and weight accumulation.

if isa(fwhh,'double')
    % Gaussian resolution function with fixed resolution
    resfun = @(Emat,center)gauss_internal(Emat,center,@(x)(fwhh+x*0));
elseif isa(fwhh,'function_handle')
    if nargin(fwhh) == 1
        % Gaussian resolution function with variable resolution
        resfun = @(Emat,center)gauss_internal(Emat,center,fwhh);
    elseif nargin(fwhh) == 2
        % Arbitrary resolution function
        resfun = fwhh;
    else
        error('disp2sqw:WrongInput','The fwhh function needs to have either one or two input parameters!');
    end
else
    error('disp2sqw:WrongInput','The fwhh parameter has to be either a scalar or function handle!');
end


if ~expand_qe
    if ~isa(fwhh,'double')
        error('disp2sqw:WrongInput','The fwhh function has to be scalar since expand_qe option is false!');
    end
    % TODO
    % only work for constant energy resolution
    sig = fwhh/sqrt(log(256));
    weight=zeros(numel(q{1}),1);
    for ii=1:numel(e)
        
        weight=weight + sf{ii}(:).*exp(-(e{ii}(:)-en(:)).^2/(2*sig^2))/(sig*sqrt(2*pi));
    end
    
    weight=reshape(weight,size(q{1}));
else
    nq = numel(q{1});
    ne = numel(en);
    weight = zeros(nq,ne);
    en_arr = repmat(en(:)',[nq,1]);
    
    for ii = 1:numel(e)
        %weight = weight + bsxfun(@times,sf{ii}(:),exp(-(bsxfun(@minus,e{ii}(:),en_arr)).^2/(2*sig.^2))./(sig*sqrt(2*pi)));
        weight = weight + bsxfun(@times,sf{ii}(:),resfun(en_arr,e{ii}(:)));
    end
end

end

function G = gauss_internal(Emat,center,FWHMfun)
% 1D Gauss function
%
% G = gauss_internal(Emat,center,FWHMfun)
%
% Input:
%
% Emat      Matrix with energy bin values, dimensions of [nQ nE].
% center    Column vector of the center of the Gaussians with nQ elements.
% FWHMfun   Function handle: dE = resfun(E), works on vectors.
%
% Output:
%
% G         Output matrix, with Gaussians, dimensions are [nQ nE].
%

% resolution for every omega values
sig = repmat(FWHMfun(center)/sqrt(log(256)),[1 size(Emat,2)]);
% intensities
G = exp(-(bsxfun(@minus,center,Emat)).^2./(2*sig.^2))./(sig*sqrt(2*pi));

end
