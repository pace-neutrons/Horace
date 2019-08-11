function [proj,pbin,mess]=make_sqw_data_calc_proj_pbin(obj,varargin)
% Create data filed for sqw object from input of the form
%
%   >> [proj,pbin,mess] = make_sqw_data_calc_proj_pbin (u1,p1,u2,p2,...,un,pn)
%   >> [proj,pbin,mess] = make_sqw_data_calc_proj_pbin (u0,u1,p1,u2,p2,...,un,pn)
%   >> [proj,pbin,mess] = make_sqw_data_calc_proj_pbin (...,'nonorthogonal')
%
%
% Input:
% ------
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
% Output:
% -------
%   proj            Projection structure or object.
%
%   pbin            Cell array of the four binning descriptors for each of the
%                  four axes of momentum and energy. They
%                  each have one fo the forms:
%                   - [pcent_lo,pstep,pcent_hi] (pcent_lo<=pcent_hi; pstep>0)
%                   - [] or empty               (interpreted as [0,0])
%
%   mess            If no problems, mess=''; otherwise contains error message


% Original author: T.G.Perring
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)


% Default return values
proj=projaxes;
pbin=cell(1,4);
mess='';

% Determine if last argument is 'nonorthogonal'
narg=numel(varargin);
if narg>=1 && is_string(varargin{end})
    if ~isempty(varargin{end}) && numel(varargin{end})<=13 &&...
            strncmpi(varargin{end},'nonorthogonal',numel(varargin{end}))
        nonorthogonal=true;
        narg=narg-1;
    else
        mess='Check argument types';
        return
    end
else
    nonorthogonal=false;
end

for i=1:narg
    if ~isnumeric(varargin{i})
        mess='Check arguments [uoffset],u1,p1,... are numeric';
        return
    end
end

% Create offset vector u0
% -----------------------
% Determine if second argument is offset, or use default
ndim=floor(narg/2);
if ndim>4 || ndim<0
    mess='Check number of arguments';
    return
end
if narg-2*ndim>0    % odd number of arguments, so first must be an offset
    ncmp = numel(varargin{1});
    if ncmp==3
        u0=[varargin{1}(:);0];
    elseif ncmp==4
        u0=varargin{1}(:);
    else
        mess='Origin offset must have form [h,k,l] or [h,k,l,e]';
        return
    end
    noff=1;
else
    u0=zeros(4,1);
    noff=0;
end

% Create proj object
% ------------------
% Get the vectors and binning for plot axes
u_to_rlu = zeros(4,4);
for i=1:ndim
    urlu=varargin{2*i-1+noff};
    ncmp=numel(urlu);
    if isnumeric(urlu) && (ncmp==3||ncmp==4)
        u_to_rlu(1:ncmp,i)=urlu(:);
    else
        mess='Check defining projection axes have form [h,k,l] or [h,k,l,e]';
        return
    end
end

% Check that there is at most one axis that is energy, and that the axes are purely energy or h,k,l;
% then circularly shift so that energy axis is highest dimension
ind_range=1:ndim;   % index to the range in the input argument list (may permute the projection axes, below)
ind_en=find(u_to_rlu(4,:)~=0);
if numel(ind_en)>1
    mess='Only one projection axis can have energy as a component';
    return
elseif numel(ind_en)==1
    if max(abs(u_to_rlu(1:3,ind_en)))~=0 || any(max(abs(u_to_rlu(:,1:ndim)),[],1)==0)
        mess='Projection axes must be purely momentum or energy';
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
        mess='Projection axes must be purely momentum or energy';
        return
    end
    u_to_rlu(4,4)=1;
elseif isempty(ind_en) && ndim==4
    mess='One of the projection axes must be energy for a 4-dimensional dataset';
    return
end

% Construct set of momentum axes
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
if nq<=2    % third axis not given, so cannot have 'p' type normalisation for third axis
    proj=projaxes(u_to_rlu(1:3,1)', u_to_rlu(1:3,2)', 'uoffset', u0(1:3), 'type', 'ppr',...
        'nonorthogonal',nonorthogonal);
else
    proj=projaxes(u_to_rlu(1:3,1)', u_to_rlu(1:3,2)', u_to_rlu(1:3,3)', 'uoffset', u0(1:3), 'type', 'ppp',...
        'nonorthogonal',nonorthogonal);
end

% Get cell array of bin descriptors
% ---------------------------------
for i=1:ndim
    pbin{i}=varargin{2*i+noff};
    if ~(isnumeric(pbin{i}) && numel(pbin{i})==3)
        mess='Check ranges have form [plo,pstep,phi]';
        return
    end
end
if ndim>0
    pbin(1:ndim)=pbin(ind_range);   % rearrange according to the circular shifting done earlier to place energy axis in 4th position
end
if ~isempty(ind_en)
    pbin=[pbin(1:ndim-1),cell(1,4-ndim),pbin(ndim)];
else
    pbin=[pbin(1:ndim),cell(1,4-ndim)];
end

% Account for energy offset in binning
if u0(4)~=0
    if isempty(pbin{4})
        pbin{4}=u0(4);  % is an integration axis; offset by u0(4)
    else
        pbin{4}=[pbin{4}(1)+u0(4),pbin{4}(2),pbin{4}(3)+u0(4)];     % plot axis; offset by u0(4)
    end
end
