function [obj,mess] = make_sqw_data_(obj,varargin)
% Make a valid data structure
% Create a valid structure for an sqw object
%
% Simplest constructor
%   >> [obj,mess] = make_sqw_data_          % assumes ndim=0
%   >> [obj,mess] = make_sqw_data_(ndim)   % sets dimensionality
%
% Old style syntax:
%   >> [obj,mess] = make_sqw_data_(u1,p1,u2,p2,...,un,pn)  % Define plot axes
%   >> [obj,mess] = make_sqw_data_(u0,...)
%   >> [obj,mess] = make_sqw_data_(lattice,...)
%   >> [obj,mess] = make_sqw_data_(lattice,u0,...)
%   >> [obj,mess] = make_sqw_data_(...,'nonorthogonal')    % permit non-orthogonal axes
%
% New style syntax:
%   >> [obj,mess] = make_sqw_data_(proj, p1_bin, p2_bin, p3_bin, p4_bin)
%   >> [obj,mess] = make_sqw_data_(lattice,...)
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
%   mess        Message; ='' if no problems, otherwise contains error message
%
%  A valid output structure contains the following fields
%
%   data.filename   Name of sqw file that is being read, excluding path
%   data.filepath   Path to sqw file that is being read, including terminating file separator
%   data.title      Title of sqw data structure
%   data.alatt      Lattice parameters for data field (Ang^-1)
%   data.angdeg     Lattice angles for data field (degrees)
%   data.uoffset    Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
%   data.u_to_rlu   Matrix (4x4) of projection axes in hkle representation
%                      u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   data.ulen       Length of projection axes vectors in Ang^-1 or meV [row vector]
%   data.ulabel     Labels of the projection axes [1x4 cell array of character strings]
%   data.iax        Index of integration axes into the projection axes  [row vector]
%                  Always in increasing numerical order
%                       e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
%   data.iint       Integration range along each of the integration axes. [iint(2,length(iax))]
%                       e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
%   data.pax        Index of plot axes into the projection axes  [row vector]
%                  Always in increasing numerical order
%                       e.g. if data is 3D, data.pax=[1,2,4] means u1, u2, u4 axes are x,y,z in any plotting
%                                       2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
%   data.p          Cell array containing bin boundaries along the plot axes [column vectors]
%                       i.e. row cell array{data.p{1}, data.p{2} ...} (for as many plot axes as given by length of data.pax)
%   data.dax        Index into data.pax of the axes for display purposes. For example we may have
%                  data.pax=[1,3,4] and data.dax=[3,1,2] This means that the first plot axis is data.pax(3)=4,
%                  the second is data.pax(1)=1, the third is data.pax(2)=3. The reason for data.dax is to allow
%                  the display axes to be permuted but without the contents of the fields p, s,..pix needing to
%                  be reordered [row vector]
%   data.s          Cumulative signal.  [size(data.s)=(length(data.p1)-1, length(data.p2)-1, ...)]
%   data.e          Cumulative variance [size(data.e)=(length(data.p1)-1, length(data.p2)-1, ...)]
%   data.npix       No. contributing pixels to each bin of the plot axes.
%                  [size(data.pix)=(length(data.p1)-1, length(data.p2)-1, ...)]
%   data.img_db_range True range of the data along each axis [img_db_range(2,4)]
%   data.pix       A PixelData object


% Original author: T.G.Perring
%

mess='';

narg = length(varargin);

if narg<=1
    % ----------------------------------------------------
    % Call of form: make_sqw_data() or make_sqw_data(ndim)
    % ----------------------------------------------------
    lattice=[2*pi,2*pi,2*pi,90,90,90];
    proj = [];
    if nargin==2
        proj = varargin{1};
    end
    if isempty(proj)
        proj = projaxes;
    end
    obj = make_sqw_data_from_proj (obj,lattice, proj);
elseif narg>=2
    % -------------------------------------------------------------------------------------
    % Call of form: make_sqw_data(u1,p1,u2,p2,...,un,pn) or make_sqw_data(proj,p1,p2,p3,p4)
    % -------------------------------------------------------------------------------------
    
    % Determine if first argument is lattice parameters
    if isnumeric(varargin{1}) && isvector(varargin{1}) && numel(varargin{1})==6
        n0=1;   % position of lattice argument in list
        latt=varargin{1};
    else
        n0=0;
        latt=[2*pi,2*pi,2*pi,90,90,90];
    end
    narg=narg-n0;   % number of arguments following lattice
    
    % Determine if remaining input is proj,p1,p2,p3,p4, or uoffset,[u0,]u1,p1,...
    if narg==5 && (isstruct(varargin{1+n0}) || isa(varargin{1+n0},'projaxes'))
        % Remaining input has form proj,p1,p2,p3,p4
        [obj,mess]=make_sqw_data_from_proj_(obj,latt,varargin{1+n0});
    else
        % Remaining input has form uoffset,[u0,]u1,p1,...
        [proj,pbin,mess]=get_projection_from_pbin_inputs_(varargin{1+n0:end});
        if ~isempty(mess)
            return
        end
        obj=make_sqw_data_from_proj_(obj,latt,proj);
    end
end
if isempty(mess)
    type_in = obj.data_type();
    [ok, ~, mess,obj]=obj.check_sqw_data_(type_in);
    if ~ok
        error('HORACE:data_sqw_dnd:invalid_arguments',mess);
    end
end
