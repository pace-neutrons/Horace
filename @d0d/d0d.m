function w = d0d (varargin)
% Create a 0D Horace dataset ('d0d')
%
% Create from file or structure:
%   >> w = d0d (filename)       % Create object from a file
%
%   >> w = d0d (din)            % Create from a structure with valid fields
%                               % Structure array will output an array of objects
%
% Create empty object suitable for simulations:
%   >> w = d0d (proj, p1_bin, p2_bin, p3_bin, p4_bin)
%   >> w = d0d (lattice, proj,...)
% 
% **Or** (old syntax, still available for legacy purposes)
%   >> w = d0d (u0)             % u0 is offset of origin of dataset,
%   >> w = d0d (lattice, u0)    % Give lattice parameters (a,b,c,alf,bet,gam)
%
%
% Input parameters in more detail:
% ----------------------------------
%   lattice Defines crystal lattice: [a,b,c,alpha,beta,gamma]
%
%   proj    Projection structure or object (see help projaxes for details)
%             proj.u              [1x3] Vector of first axis (r.l.u.)
%             proj.v              [1x3] Vector of second axis (r.l.u.)
%             proj.w              [1x3] Vector of third axis (r.l.u.)
%                                 (set to [] if not given in proj_in)
%             proj.nonorthogonal  logical true or false
%             proj.type           [1x3] Char. string defining normalisation
%                                 each character being 'a','r' or 'p' e.g. 'rrp'
%             proj.uoffset        [4x1] column vector of offset of origin of
%                                 projection axes (r.l.u. and en)
%             proj.lab            [1x4] cell array of projection axis labels
%
%   p1_bin---Binning descriptors, that give bin boundaries or integration
%   p2_bin | ranges for each of the four axes of momentum and energy. They
%   p3_bin | each have one fo the forms:
%   p4_bin-|    - [pcent_lo,pstep,pcent_hi] (pcent_lo<=pcent_hi; pstep>0)
%               - [pint_lo,pint_hi]         (pint_lo<=pint_hi)
%               - [pint]                    (interpreted as [pint,pint]
%               - [] or empty               (interpreted as [0,0]
%               - scalar numeric cellarray  (interpreted as bin boundaries)
%            For a d0d object, none of the four descriptors must correspond
%            to bin boundaries, and all to integration axes.
%   
% **OR**
%
%   u0      Vector of form [h0,k0,l0] or [h0,k0,l0,en0]
%          that defines an origin point on the manifold of the dataset.
%          If en0 omitted, then assumed to be zero.


% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)


ndim_request = 0;
class_type = 'd0d';
inferiorto('sqw');

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if nargin==1 && isa(varargin{1},class_type)     % already object of class
    w = varargin{1};
    return
end

if nargin==0
    w = sqw('$dnd',ndim_request); % default constructor
else
    w = sqw('$dnd',varargin{:});
    if dimensions(w)~=ndim_request
        error(['Input arguments inconsistent with requested dimensionality ',num2str(ndim_request)])
    end
end

if isa(w.data,'data_sqw_dnd')
    w=class(w.data.get_dnd_data(),class_type);
else
    w=class(w.data,class_type);
end

