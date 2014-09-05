function [data,mess] = make_sqw_data (varargin)
% Make a valid structure for a dnd-type sqw object
%
%   >> [data,mess] = make_sqw_data (u1,p1,u2,p2,...,un,pn)  % Define plot axes
%   >> [data,mess] = make_sqw_data (u0,...)
%   >> [data,mess] = make_sqw_data (lattice,...)
%   >> [data,mess] = make_sqw_data (lattice,u0,...)
%
%   >> [data,mess] = make_sqw_data (ndim)
%
% Input:
% -------
%   u0      Vector of form [h0,k0,l0] or [h0,k0,l0,en0]
%          that defines an origin point on the manifold of the dataset.
%          If en0 omitted, then assumed to be zero.
%   u1      Vector [h1,k1,l1] or [h1,k1,l1,en1] defining a plot axis. Must
%          not mix momentum and energy components e.g. [1,1,2], [0,2,0,0] and
%          [0,0,0,1] are valid; [1,0,0,1] is not.
%   p1      Vector of form [plo,delta_p,phi] that defines bin centres and step size
%          in multiples of u1.
%   u2,p2   For next plot axis
%
%       [If un is omitted, then it is assumed to be [0,0,0,1] i.e. the energy axis]
%
%   lattice Defines crystal lattice: [a,b,c,alpha,beta,gamma]
%
%   ndim    Number of dimensions
%
%
% Output:
% -------
%
%   data        Output data structure for a valid dnd-type sqw object
%
%   mess        Message; ='' if no problems, otherwise contians error message
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
%   data.s          Average signal.  [size(data.s)=(length(data.p1)-1, length(data.p2)-1, ...)]
%   data.e          Average variance [size(data.e)=(length(data.p1)-1, length(data.p2)-1, ...)]
%   data.npix       No. contributing pixels to each bin of the plot axes.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


data=[];
mess='';

narg = length(varargin);

if narg==0 || (narg==1 && isscalar(varargin{1}) && isnumeric(varargin{1}))
    % Call of form: make_sqw_data or make_sqw_data(ndim)
    if narg==0
        ndim=0;
    else
        ndim=varargin{1};
    end
    if ndim==0 || ndim==1 || ndim==2 || ndim==3 || ndim==4
        data.filename = '';
        data.filepath = '';
        data.title = '';
        data.alatt = [2*pi, 2*pi, 2*pi];
        data.angdeg = [90, 90, 90];
        data.uoffset = zeros(4,1);
        data.u_to_rlu = eye(4);
        data.ulen=[1,1,1,1];
        data.ulabel={'\zeta','\xi','\eta','E'};
        data.iax=ndim+1:4;
        data.iint=zeros(2,size(data.iax,2));
        data.pax=1:ndim;
        data.p=repmat({[0;1]},1,ndim);
        data.dax=1:ndim;
        data.s=0;
        data.e=0;
        data.npix=1;
    else
        mess='ERROR: Numeric input must be 0,1,2,3 or 4 to create empty dataset';
        return
    end
    
elseif narg>=1
    
    % Determine if first argument is lattice parameters
    if isnumeric(varargin{1}) && isvector(varargin{1}) && length(varargin{1})==6
        n0=1;   % position of lattice argument in list
        latt=varargin{1};
    else
        n0=0;
        latt=[2*pi,2*pi,2*pi,90,90,90];
    end
    
    % Determine if second argument is offset
    narg=narg-n0;   % number of arguments following lattice
    ndim=floor(narg/2);
    if ndim>4, mess='ERROR: Check number of arguments'; return; end;    % Too many arguments
    if narg-2*ndim>0    % odd number of arguments, so first must be an offset
        n0=n0+1;
        ncmp = length(varargin{n0});
        if ncmp==3
            u0(1:3,1)=varargin{n0};
            u0(4,1)=0;
        elseif ncmp==4
            u0(1:4,1)=varargin{n0};
        else
            mess='ERROR: Origin offset must have form [h,k,l] or [h,k,l,e]';
            return
        end
    else
        u0=zeros(4,1);
    end
    
    % Get the vectors and binning for plot axes
    u_to_rlu = zeros(4);
    for i=1:ndim
        ncmp=length(varargin{2*i-1+n0});
        if ncmp==3||ncmp==4
            u_to_rlu(1:ncmp,i)=varargin{2*i-1+n0};
        else
            mess='ERROR: Check defining projection axes have form [h,k,l] or [h,k,l,e]';
            return
        end
    end
    
    % Check that there is at most one axis that is energy, and that the axes are purely energy or h,k,l;
    % then circularly shift so that energy axis is highest dimension
    ind_range=1:ndim;   % Index to the range in the input argument list (may permute the projection axes, below)
    ind_en=find(u_to_rlu(4,:)~=0);
    if length(ind_en)>1
        mess='ERROR: Only one projection axis can have energy as a component';
        return
    elseif length(ind_en)==1
        if max(abs(u_to_rlu(1:3,ind_en)))~=0 || any(max(abs(u_to_rlu(:,1:ndim)),[],1)==0)
            mess='ERROR: Projection axes must be purely momentum or energy';
            return
        end
        nshift=ndim-ind_en;
        if nshift~=0
            u_to_rlu(:,1:ndim)=circshift(u_to_rlu(:,1:ndim),[0,nshift]);
            ind_range=circshift(ind_range,[0,nshift]);
        end
        if ndim<4
            u_to_rlu(4,4)=u_to_rlu(4,ndim);
            u_to_rlu(4,ndim)=0;
        end
    elseif isempty(ind_en) && ndim<4
        if any(max(abs(u_to_rlu(:,1:ndim)),[],1)==0)
            mess='ERROR: Projection axes must be purely momentum or energy';
            return
        end
        u_to_rlu(4,4)=1;
    elseif isempty(ind_en) && ndim==4
        mess='ERROR: One of the projection axes must be energy for a 4-dimensional dataset';
        return
    end
 
    % Construct orthogonal set of momentum axes
    nq=ndim-length(ind_en);    % Number of Q axes
    if nq==0    % either 0D dataset, or 1D dataset with energy axis as projection axis
        u_to_rlu(1:3,1:2)=[1,0,0;0,1,0]';
    elseif nq==1
        if u_to_rlu(2,1)==0 && u_to_rlu(3,1)==0    % u1 parallel to a*
            u_to_rlu(1:3,2)=[0,1,0];   % make u2 parallel to b*
        else
            u_to_rlu(1:3,2)=[1,0,0];   % make u2 parallel to a*
        end
    end
    if nq<=2    % third axis not give, so cannot have 'p' type normalisation for third axis
        [rlu_to_ustep, u_to_rlu, ulen, mess] = ...
            rlu_to_ustep_matrix (latt(1:3), latt(4:6), u_to_rlu(1:3,1)', u_to_rlu(1:3,2)', [1,1,1], 'ppr');
    else
        [rlu_to_ustep, u_to_rlu, ulen, mess] = ...
            rlu_to_ustep_matrix (latt(1:3), latt(4:6), u_to_rlu(1:3,1)', u_to_rlu(1:3,2)', [1,1,1], 'ppp', u_to_rlu(1:3,3)');
    end
    if ~isempty(mess)   % problem calculating ub matrix and related quantities
        mess='ERROR: Check lattice parameters and that u1 and u2 are not parallel';
        return
    end
    
    % Extract the ranges
    urange=zeros(3,ndim);
    pvals=cell(1,3);
    for i=1:ndim
        j=2*i+n0;
        ncmp=length(varargin{j});
        if ncmp==3
            urange(:,i)=varargin{j};
            % Replace the following line to avoid rounding errors when e.g. urange(:,1)=[0,0.1,1]
            % pvals{i}=[(urange(1,i)-urange(2,i)/2):urange(2,i):(urange(3,i)+urange(2,i)/2)]';
            if urange(2,i)<=0 || urange(3,i)<=urange(1,i)
                mess='ERROR: Check that ranges have form [plo,delta_p,phi], plo<phi and delta_p>0';
                return
            end
            % If energy is a plot axis, then absorb any offset into the range
            if nq~=ndim && i==ind_en
                urange(1,i)=urange(1,i)+u0(4);
                urange(3,i)=urange(3,i)+u0(4);
            end
            pvals{i}=(urange(1,i)-urange(2,i)/2:urange(2,i):urange(3,i)+urange(2,i)/2)';
            if pvals{i}(end)<urange(3,i)
                pvals{i}=[pvals{i};pvals{i}(end)+urange(2,i)];
            elseif pvals{i}(end-1)>=urange(3,i)
                pvals{i}=pvals{i}(1:end-1);
            end
        else
            mess='ERROR: Check ranges have form [plo,delta_p,phi]';
            return
        end
    end
    if ndim>0
        pvals=pvals(ind_range);     % rearrange according to the circular shifting done earlier to place energy axis in 4th position
    end
    
    % Fill the output structure
    data.filename = '';
    data.filepath = '';
    data.title = '';
    data.alatt=latt(1:3);
    data.angdeg=latt(4:6);
    data.uoffset=[u0(1:3);0];   % will absorb the energy offset into integration or plot axis
    data.u_to_rlu=zeros(4); data.u_to_rlu(1:3,1:3)=u_to_rlu; data.u_to_rlu(4,4)=1;
    data.ulen=[ulen,1];
    data.ulabel={'\zeta','\xi','\eta','E'};
    if nq==ndim     % energy is an integration axis
        data.iax=ndim+1:4;
        data.iint=[zeros(2,size(data.iax,2)-1),[u0(4);u0(4)]];
        data.pax=1:ndim;
    else            % energy is a plot axis
        data.iax=nq+1:3;
        data.iint=zeros(2,size(data.iax,2));
        data.pax=[1:nq,4];
    end
    if ndim==0
        data.p=cell(1,0);
        data.dax=zeros(1,0);
        data.s=0;
        data.e=0;
        data.npix=1;
    else
        data.p=pvals;
        [dummy,data.dax]=sort(ind_range);
        data_size=zeros(1,ndim);
        for i=1:ndim
            data_size(i)=length(pvals{i})-1;
        end
        if length(data_size)==1, data_size=[data_size,1]; end
        data.s=zeros(data_size);
        data.e=zeros(data_size);
        data.npix=ones(data_size);
    end
end
