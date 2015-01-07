function weight = disp2sqw(varargin)
% Calculate spectral weight at a set of points given dispersion relation and spectral weight
%
%   >> weight = disp2sqw(qh,qk,ql,en,dispreln,pars,fwhh)
%   >> weight = disp2sqw(q,en,dispreln,pars,fwhh)
%
% Input:
% ------
%   qh,qk,ql,en Arrays containing points at which to evaluate sqw from the broadened dispersion
%     *OR*
%   q           Cell array of three arrays {qh,qk,ql} at which to evaluate the dispersion
%   en          Array of energy transfers at which the broadened dispersion is evaluate for every q
%
%   dispreln    Handle to function that calculates the dispersion relation w(Q) and spectrl weight, s(Q)
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
%   pars        Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
%   fwhh        Full-width half-height of Gaussian broadening to dispersion relation(s)
%
% Output:
% -------
%   weight      Array with spectral weight at the q,e points
%               If q and en given:  weight is an nq x ne array, where nq is the number
%                                   of q points, and ne the number of energy points
%               If qw given together: weight has the same size and dimensions as q{1} i.e. qh

% Parse input arguments
%disp2sqw(qh,qk,ql,en,dispreln,pars,fwhh)
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
    for i=1:numel(e)
        sf{i}=ones(size(e{i}));
    end
else
    [e,sf]=dispreln(q{:},pars{:});
    if ~iscell(e)   % convert to cell array for convenience
        e={e};
        sf={sf};
    end
end

% Accumulate weight
sig=fwhh/sqrt(log(256));
if ~expand_qe
    weight=zeros(numel(q{1}),1);
    for i=1:numel(e)
        weight=weight + sf{i}(:).*exp(-(e{i}(:)-en(:)).^2/(2*sig^2))/(sig*sqrt(2*pi));
    end
    weight=reshape(weight,size(q{1}));
else
    nq=numel(q{1});
    ne=numel(en);
    weight=zeros(nq,ne);
    en_arr=repmat(en(:)',[nq,1]);
    for i=1:numel(e)
        edisp=repmat(e{i}(:),[1,ne]);
        sfact=repmat(sf{i}(:),[1,ne]);
        weight=weight + sfact.*exp(-(edisp-en_arr).^2/(2*sig.^2))./(sig*sqrt(2*pi));
    end
end
