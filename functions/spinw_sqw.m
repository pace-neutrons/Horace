function weight = spinw_sqw(varargin)
% Calculate spectral weight from a spinW model.
%
%   >> weight = disp2sqw(qh,qk,ql,en,pars,swobj)
%
% Input:
% ------
%   qh,qk,ql,en Arrays containing points at which to evaluate sqw from the
%               broadened dispersion
%     *OR*
%   q           Cell array of three arrays {qh,qk,ql} at which to evaluate
%               the dispersion
%
%   en          Array of energy transfers at which the broadened dispersion
%               is evaluate for every q
%
%   pars        Arguments needed by the function.
%               - Should be a vector of parameters
%               - The first N parameters relate to the spin wave dispersion
%                 and correspond to spinW matrices in the order defined by
%                 the 'mapping' option of spinw_setpar() [N=numel(mapping)]
%               - The next M parameters relate to the convolution parameters
%                 corresponding to the convolution function defined by the
%                 'convolvfn' option of spinw_setpar() [M=3 for 
%                 spinw_gauss_sqw, which is the default convolution function] 
%
%   swobj       The spinwave object which defines the magnetic system to be
%               calculated.
%
% Output:
% -------
%   weight      Array with spectral weight at the q,e points
%               If q and en given:  weight is an nq x ne array, where nq
%                                   is the number of q points, and ne the
%                                   number of energy points
%               If qw given together: weight has the same size and dimensions
%                                     as q{1} i.e. qh
%
% Example:
% --------
%
% tri = sw_model('triAF',[5 1]);                         % J1=5, J2=1 (AFM)
% tri = spinw_setpar(tri,'mapping',{'J1','J2'});
% tri = spinw_setpar(tri,'convolvfn',@spinw_sho_sqw);
% [wf,fp] = fit_sqw(w1,@spinw_sqw,{[J1 J2 gam T ampli] tri});

% Original author: Duc Le
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)

% Parse input arguments
if nargin==6
    expand_qe=false;    % set of distinct q points
    q=varargin(1:3);
    en=varargin{4};
    pars=varargin{5};
    swobj=varargin{6};
elseif nargin==4
    expand_qe=true;     % same q array for each energy in the energy array
    q=varargin{1};
    en=varargin{2};
    pars=varargin{3};
    swobj=varargin{4};
elseif nargin==3
    expand_qe=false;
    q=varargin{1}(1:3);
    en=varargin{1}{4};
    pars=varargin{2};
    swobj=varargin{3};
else
    error('Check number of input arguments')
end

% Check input is actually a spinW object, taking care of v3 nameing conventions.
if ~isa(swobj,'sw') && ~isa(swobj,'spinw')
    error('swobj should be a spinW object');
end

% If no parameters set so far, set default parameters
if ~isfield(swobj.matrix,'horace')
    swobj = spinw_setpar(swobj);
end

weight = swobj.matrix.horace.convolvfn(swobj,q{1:3},en,swobj.matrix.horace.partrans(pars));
