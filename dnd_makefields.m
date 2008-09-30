function [w, mess] = dnd_makefields (ndim,varargin)
% Create a valid structure for an n-dimensional dataset
%
%   >> [w,message] = dnd_makefields (n)
%   >> [w,message] = dnd_makefields (n,u0,u1,p1,u2,p2,...,un,pn)
%   >> [w,message] = dnd_makefields (n,u0,u1,p1,u2,p2,...,un-1,pn-1,pn)
%   >> [w,message] = dnd_makefields (lattice,u0,...)
%
%   n       Number of dimensions
%   lattice Defines crystal lattice: [a,b,c,alpha,beta,gamma]
%   u0      Vector of form [h0,k0,l0] or [h0,k0,l0,en0]
%          that defines an origin point on the manifold of the dataset.
%          If en0 omitted, then assumed to be zero.
%   u1      Vector [h1,k1,l1] or [h1,k1,l1,en1] defining a plot axis. Must
%          not mix momentum and energy components e.g. [1,1,2], [0,2,0,0] and
%          [0,0,0,1] are valid; [1,0,0,1] is not.
%   p1      Vector of form [plo,delta_p,phi] that defines limits and step
%          in multiples of u1.
%   u2,p2   For next plot axis
%
%   If un is omitted, then it is assumed to be [0,0,0,1] i.e. the energy axis.
%
% Note: the dimension argument is currently redundant. However, since the
%       only route to call this routine is via the constructor for specific
%       dimensionality, we have this information anyway.

w=[];
mess=[];

narg = length(varargin);
if narg==0
    % Call of form: dnd_makefields(ndim)
    if ndim==0 || ndim==1 || ndim==2 || ndim==3 || ndim==4
        w.file='';
        w.grid='orthogonal-grid';
        w.title='';
        w.a=2*pi; w.b=2*pi; w.c=2*pi; w.alpha=90; w.beta=90; w.gamma=90;
        w.u=zeros(4,4); w.u(4,4)=1; % must give an energy axis
        w.ulen=[1,1,1,1];
        w.label={'Q_h','Q_k','Q_l','E'};
        w.p0=[0;0;0;0];
        w.pax=1:ndim;
        w.iax=ndim+1:4;
        w.uint=zeros(2,size(w.iax,2));
        if ndim>0
            for i=1:ndim
                w.(['p',int2str(i)])=[0;1];
            end
        end
        w.s=0;
        w.e=0;
        if ndim<4
            w.n=1;
        else
            w.n=int16(1);
        end
    else
        mess='ERROR: Numeric input must be 0,1,2,3 or 4 to create empty dataset';
        return
    end
    
elseif narg>=1
    
    % Determine if first argument is lattice parameters
    if isnumeric(varargin{1}) && isvector(varargin{1}) && length(varargin{1})==6
        n0=2;   % position of u0 in argument list
        latt=varargin{1};
    else
        n0=1;
        latt=[2*pi,2*pi,2*pi,90,90,90];
    end

    narg=narg-n0;   % number of arguments following u0
    if narg<0; mess='ERROR: Check arguments'; return; end;   % No u0 argument
    if ndim~=ceil(narg/2); mess='ERROR: Check number of arguments'; return; end;    % Incorrect number of u's and p's
    implicit_en_axis=2*ndim-narg;   % =1 if the last axis is implicitly energy
    
    % Extract u0,u1,u2,...
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
    
    u = zeros(4,4);
    for i=1:ndim-implicit_en_axis
        ncmp=length(varargin{2*i-1+n0});
        if ncmp==3||ncmp==4
            u(1:ncmp,i)=varargin{2*i-1+n0};
        else
            mess='ERROR: Check defining projection axes have form [h,k,l] or [h,k,l,e]';
            return
        end
    end
    if implicit_en_axis
        u(:,ndim)=[0,0,0,1];
    end
    
    % Check that there is at most one axis that is energy, and that the axes are purely energy or h,k,l;
    % then circularly shift so that energy axis is highest dimension
    ind_range=1:ndim;   % Index to the range in the input argumnet list (may permute the projection axes, below)
    ind_en=find(u(4,:)~=0);
    if length(ind_en)>1
        mess='ERROR: Only one projection axis can have energy as a component';
        return
    elseif length(ind_en)==1
        if max(abs(u(1:3,ind_en)))~=0 || any(max(abs(u(:,1:ndim)),[],1)==0)
            mess='ERROR: Projection axes must be purely momentum or energy';
            return
        end
        nshift=ndim-ind_en;
        if nshift~=0
            u(:,1:ndim)=circshift(u(:,1:ndim),[0,nshift]);
            ind_range=circshift(ind_range,[0,nshift]);
        end
        if ndim<4
            u(4,4)=u(4,ndim);
            u(4,ndim)=0;
        end
    elseif length(ind_en)==0 && ndim<4
        if any(max(abs(u(:,1:ndim)),[],1)==0)
            mess='ERROR: Projection axes must be purely momentum or energy';
            return
        end
        u(4,4)=1;
    elseif length(ind_en)==0 && ndim==4
        mess='ERROR: One of the projection axes must be energy for a 4-dimensional dataset';
        return
    end
 
    % Construct orthogonal set of momentum axes
    nq=ndim-length(ind_en);    % Number of Q axes
    if nq==0    % either 0D dataset, or 1D dataset with energy axis as projection axis
        u(1:3,1:2)=[1,0,0;0,1,0]';
    elseif nq==1
        if u(2,1)==0 & u(3,1)==0    % u1 parallel to a*
            u(1:3,2)=[0,1,0];   % make u2 parallel to b*
        else
            u(1:3,2)=[1,0,0];   % make u2 parallel to a*
        end
    end

    small = 1.0e-13;
    [rlu_to_ustep, u_to_rlu, ulen, mess] = rlu_to_ustep_matrix (latt(1:3), latt(4:6), u(1:3,1)', u(1:3,2)', [1,1,1], 'rrr');
    if ~isempty(mess)   % problem calculating ub matrix and related quantities
        mess='ERROR: Check lattice parameters and that u1 and u2 are not parallel';
        return
    end
    
    % Extract the ranges
    urange=zeros(3,ndim);
    for i=1:ndim
        if i==ndim & implicit_en_axis
            j=2*i+n0-1;
        else
            j=2*i+n0;
        end
        ncmp=length(varargin{j});
        if ncmp==3
            urange(:,i)=varargin{j};
            % Replace the following line to avoid rounding errors when e.g. urange(:,1)=[0,0.1,1]
            % pvals{i}=[(urange(1,i)-urange(2,i)/2):urange(2,i):(urange(3,i)+urange(2,i)/2)]';
            if urange(2,i)<=0 || urange(3,i)<=urange(1,i)
                mess='ERROR: Check that ranges have form [plo,delta_p,phi], plo<phi and delta_p>0';
                return
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
    
    % Fill the output structure
    w.file='';
    w.grid='orthogonal-grid';
    w.title='';
    w.a=latt(1); w.b=latt(2); w.c=latt(3); w.alpha=latt(4); w.beta=latt(5); w.gamma=latt(6);
    w.u=u; w.u(1:3,1:3)=u_to_rlu;
    w.ulen=[ulen,u(4,4)];
    w.label={'\zeta','\xi','\eta','E'};
    w.p0=u0;
    if nq==ndim 
        w.pax=1:ndim;
        w.iax=ndim+1:4;
    else
        w.pax=[1:nq,4];
        w.iax=nq+1:3;
    end
    w.uint=zeros(2,size(w.iax,2));
    if ndim==0
        w.s=0;
        w.e=0;
        w.n=0;
    else
        data_size=[];
        for i=1:ndim
            w.(['p',int2str(i)])=pvals{ind_range(i)};
            data_size=[data_size,length(pvals{ind_range(i)})-1];
        end
        if length(data_size)==1, data_size=[data_size,1]; end
        w.s=zeros(data_size);
        w.e=zeros(data_size);
        if ndim<4
            w.n=ones(data_size);
        else
            w.n=ones(data_size,'int16');
        end
    end
end
