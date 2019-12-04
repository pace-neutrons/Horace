function w = d1d (varargin)
% Create a 1D Horace dataset ('d1d')
%
% Create from file or structure:
%   >> w = d1d (filename)       % Create object from a file
%
%   >> w = d1d (din)            % Create from a structure with valid fields
%                               % Structure array will output an array of objects
%
% Create empty object suitable for simulations:
%   >> w = d1d (proj, p1_bin, p2_bin, p3_bin, p4_bin)
%   >> w = d1d (lattice, proj,...)
% 
% **Or** (old syntax, still available for legacy purposes)
%   >> w = d1d (u1,p1      )    % u1,u2 vectors define projection axes in rlu,
%                                 p1,p2 give start,step and finish for the axes
%   >> w = d1d (u0,...)         % u0 is offset of origin of dataset,
%   >> w = d1d (lattice,...)    % Give lattice parameters [a,b,c,alf,bet,gam]
%   >> w = d1d (lattice,u0,...) % Give u0 and lattice parameters
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
%            For a d1d object, one of the four descriptors must correspond
%            to bin boundaries, and the other three to integration axes.
%   
% **OR**
%
%   u0      Vector of form [h0,k0,l0] or [h0,k0,l0,en0]
%          that defines an origin point on the manifold of the dataset.
%          If en0 omitted, then assumed to be zero.
%   u1      Vector [h1,k1,l1] or [h1,k1,l1,en1] defining a plot axis. Must
%          not mix momentum and energy components e.g. [1,1,2], [0,2,0,0] and
%          [0,0,0,1] are valid; [1,0,0,1] is not.
%   p1      Vector of form [plo,delta_p,phi] that defines limits and step
%          in multiples of u1.


% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)


ndim_request = 1;
class_type = 'd1d';
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
