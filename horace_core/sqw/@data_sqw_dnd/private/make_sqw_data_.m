function obj = make_sqw_data_(obj,uoffset,varargin)
% Make a valid sqw_dnd_data object from sequence of various inputs
%
% Create a valid structure for an sqw object
%
% Simplest constructor
%   >> obj = make_sqw_data_          % assumes ndim=0
%   >> obj = make_sqw_data_(ndim)   % sets dimensionality
%
% Old style syntax:
%   >> obj = make_sqw_data_(u1,p1,u2,p2,...,un,pn)  % Define plot axes
%   >> obj = make_sqw_data_(u0,...)
%   >> obj = make_sqw_data_(lattice,...)
%   >> obj = make_sqw_data_(lattice,u0,...)
%   >> obj = make_sqw_data_(...,'nonorthogonal')    % permit non-orthogonal axes
%
% New style syntax:
%   >> obj = make_sqw_data_(proj, p1_bin, p2_bin, p3_bin, p4_bin)
%   >> obj = make_sqw_data_(lattice,...)
%
%
% Input:
% -------
%   ndim            Number of dimensions
%
% **OR**
%   lattice         [Optional] Defines crystal lattice: [a,b,c,alpha,beta,gamma]
%                  Assumes to be [2*pi,2*pi,2*pi,90,90,90] if not given.
%
%   u0              [Optional] Vector of form [h0,k0,l0] or [h0,k0,l0,en0]
%                  that defines an origin point on the manifold of the dataset.
%                   If en0 omitted, then assumed to be zero.
%
%   u1              Vector [h1,k1,l1] or [h1,k1,l1,en1] defining a plot axis. Must
%                  not mix momentum and energy components e.g. [1,1,2], [0,2,0,0] and
%                  [0,0,0,1] are valid; [1,0,0,1] is not.
%
%   p1              Vector of form [plo,delta_p,phi] that defines bin centres
%                  and step size in multiples of u1.
%
%   u2,p2           For next plot axis
%    :                  :
%
%   'nonorthogonal' Keyword that permits the projection axes to be non-orthogonal
%
% **OR**
%   lattice         [Optional] Defines crystal lattice: [a,b,c,alpha,beta,gamma]
%                  Assumes to be [2*pi,2*pi,2*pi,90,90,90] if not given.
%
%   proj            Projection structure or object.
%
%   p1_bin,p2_bin.. Binning descriptors, that give bin boundaries or integration
%                  ranges for each of the four axes of momentum and energy. They
%                  each have one fo the forms:
%                   - [pcent_lo,pstep,pcent_hi] (pcent_lo<=pcent_hi; pstep>0)
%                   - [pint_lo,pint_hi]         (pint_lo<=pint_hi)
%                   - [pint]                    (interpreted as [pint,pint]
%                   - [] or empty               (interpreted as [0,0]
%                   - scalar numeric cellarray  (interpreted as bin boundaries)
%
% Output:
% -------
%
%   data        Output data structure which must contain the fields listed below
%                       type 'b+'   fields: uoffset,...,s,e,npix
%               [The following other valid structures are not created by this function
%                       type 'b'    fields: uoffset,...,s,e
%                       type 'a'    uoffset,...,s,e,npix,img_db_range,pix
%                       type 'a-'   uoffset,...,s,e,npix,img_db_range   ]
%
%

% Original author: T.G.Perring
%


narg = length(varargin);

if narg<=1
    % ----------------------------------------------------
    % Call of form: make_sqw_data() or make_sqw_data(ndim)
    % ----------------------------------------------------
    proj = [];
    if nargin==3
        proj = varargin{1};
        if isstruct(proj)
            proj = ortho_proj(proj);
        end
    end
    if isempty(proj)
        proj = ortho_proj;
    end
    proj.offset = uoffset;
    obj = make_sqw_data_from_proj_(obj,proj);
elseif narg>=2
    % -------------------------------------------------------------------------------------
    % Call of form: make_sqw_data(u1,p1,u2,p2,...,un,pn) or make_sqw_data(proj,p1,p2,p3,p4)
    % -------------------------------------------------------------------------------------

    % Determine if first argument is lattice parameters
    if (isnumeric(varargin{1}) && isvector(varargin{1}) && numel(varargin{1})==6)...
            || isa(varargin{1},'oriented_lattice')...

        n0=1;   % position of lattice argument in list
    else
        n0=0;
    end
    narg=narg-n0;   % number of arguments following lattice

    % Determine if remaining input is proj,p1,p2,p3,p4, or uoffset,[u0,]u1,p1,...

    if narg==1 && (isstruct(varargin{1+n0}) || isa(varargin{1+n0},'aProjection'))
        % Remaining input has form proj,p1,p2,p3,p4
        obj=make_sqw_data_from_proj_(obj,varargin{1+n0});
    else
        proj = ortho_proj(varargin{:});
        obj=make_sqw_data_from_proj_(obj,proj);
    end
end

type_in = obj.data_type();
[~,obj]=obj.check_sqw_data_(type_in);

