function [pbin,u0,remains]=make_sqw_data_shifted_pbin_(varargin)
% Create data filed for sqw object from input of the form
%
%   >> [pbin,remains] = make_sqw_data_calc_proj_pbin (u1,p1,u2,p2,...,un,pn)
%   >> [pbin,remains] = make_sqw_data_calc_proj_pbin (u0,u1,p1,u2,p2,...,un,pn)
%   >> [pbin,remains] = make_sqw_data_calc_proj_pbin (...,'nonorthogonal')
%
%
% Input:
% ------
%   u0          [Optional] Vector of form [h0,k0,l0] or [h0,k0,l0,en0]
%               that defines an origin point on the manifold of the dataset.
%               If en0 omitted, then assumed to be zero.
%
%   u1          Vector [h1,k1,l1] or [h1,k1,l1,en1] defining a plot axis. Must
%               not mix momentum and energy components e.g. [1,1,2], [0,2,0,0] and
%               [0,0,0,1] are valid; [1,0,0,1] is not.
%
%   p1          Vector of form [plo,delta_p,phi] that defines bin centres
%               and step size in multiples of u1.
%
%   u2,p2       For next plot axis
%    :                  :
%
%   'nonorthogonal' Keyword that permits the projection axes to be non-orthogonal
%
% Output:
% -------
%   remains     things related to projection, which are not processed by
%               this routine
%
%   pbin        Cell array of the four binning descriptors for each of the
%               four axes of momentum and energy. They
%               each have one fo the forms:
%               - [pcent_lo,pstep,pcent_hi] (pcent_lo<=pcent_hi; pstep>0)
%               - [] or empty               (interpreted as [0,0])
%


% Original author: T.G.Perring
%


pbin=cell(1,4);
remains = {};
% Determine if last argument is 'nonorthogonal'
narg=numel(varargin);
if narg>=1 && is_string(varargin{end})
    if ~isempty(varargin{end}) && numel(varargin{end})<=13 &&...
            strncmpi(varargin{end},'nonorthogonal',numel(varargin{end}))
        narg=narg-1;
        remains = {'nonorthogonal'};
    else
        error('HORACE:axes_block:invalid_argument',...
            'Invalid argument types')
    end
else
end

for i=1:narg
    if ~isnumeric(varargin{i})
        error('HORACE:axes_block:invalid_argument',...
            'Arguments [uoffset],u1,p1,... should be numeric. Argument N%d is invalid: %s',...
            i,evalc('disp(varargin{i})'));
    end
end

% Create offset vector u0
% -----------------------
% Determine if second argument is offset, or use default
ndim=floor(narg/2);
if ndim>4 || ndim<0
    error('HORACE:axes_block:invalid_argument',...
        'Number of axes arguments must be even and smaller then 8. It is: %d',...
        narg)
end
if narg-2*ndim>0    % odd number of arguments, so first must be an offset
    ncmp = numel(varargin{1});
    if ncmp==3
        u0=[varargin{1}(:);0];
    elseif ncmp==4
        u0=varargin{1}(:);
    else
        error('HORACE:axes_block:invalid_argument',...
            'Origin offset must have form [h,k,l] or [h,k,l,e]');
    end
    noff=1;
else
    u0=zeros(4,1);
    noff=0;
end

% Create proj object
% ------------------
remains=[remains{:}, varargin(1+noff:end)];
[ind_range,ind_en]=get_projection_from_pbin_inputs_(ndim,varargin{noff-1:end});

% Get cell array of bin descriptors
% ---------------------------------
for i=1:ndim
    pbin{i}=varargin{2*i+noff};
    if ~(isnumeric(pbin{i}) && numel(pbin{i})==3)
        error('HORACE:axes_block:invalid_argument',...
            'Ranges have to have form [plo,pstep,phi] but are: %s',...
            evalc('disp(pbin{i})'));
    end
end
if ndim>0
    pbin(1:ndim)=pbin(ind_range);   % rearrange according to the circular shifting done earlier to place energy axis in 4th position
end
rest = arrayfun(@(x)zeros(1,0),1:4-ndim,'UniformOutput',false);
if ~isempty(ind_en)
    pbin=[pbin(1:ndim-1),rest,pbin(ndim)];
else
    pbin=[pbin(1:ndim),rest];
end

% Account for energy offset in binning
if u0(4)~=0
    if isempty(pbin{4})
        pbin{4}=u0(4);  % is an integration axis; offset by u0(4)
    else
        pbin{4}=[pbin{4}(1)+u0(4),pbin{4}(2),pbin{4}(3)+u0(4)];     % plot axis; offset by u0(4)
    end
end

function [ind_range,ind_en,u_to_rlu]=check_projection(ndim,noff,varargin)
% NOT UNIT TESTED. Usage unknown -- very complicated. Leave for the time
% being but remove after some efforts
%
% Get the vectors and binning for plot axes
u_to_rlu = zeros(4,4);
for i=1:ndim
    urlu=varargin{2*i-1+noff};
    ncmp=numel(urlu);
    if isnumeric(urlu) && (ncmp==3||ncmp==4)
        u_to_rlu(1:ncmp,i)=urlu(:);
    else
        error('HORACE:axes_block:invalid_argument',...
            'Check defining projection axes have form [h,k,l] or [h,k,l,e]');
    end
end

% Check that there is at most one axis that is energy, and that the axes are purely energy or h,k,l;
% then circularly shift so that energy axis is highest dimension
ind_range=1:ndim;   % index to the range in the input argument list (may permute the projection axes, below)
ind_en=find(u_to_rlu(4,:)~=0);
if numel(ind_en)>1
    error('HORACE:axes_block:invalid_argument',...
        'Only one projection axis can have energy as a component');
    
elseif numel(ind_en)==1
    if max(abs(u_to_rlu(1:3,ind_en)))~=0 || any(max(abs(u_to_rlu(:,1:ndim)),[],1)==0)
        error('HORACE:axes_block:invalid_argument',...
            'Projection axes must be purely momentum or energy');
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
        error('HORACE:axes_block:invalid_argument',...
            'Projection axes must be purely momentum or energy');
    end
    u_to_rlu(4,4)=1;
elseif isempty(ind_en) && ndim==4
    error('HORACE:axes_block:invalid_argument',...
        'One of the projection axes must be energy for a 4-dimensional dataset');
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
% if nq<=2    % third axis not given, so cannot have 'p' type normalisation for third axis
%     proj=projaxes(u_to_rlu(1:3,1)', u_to_rlu(1:3,2)', 'uoffset', u0(1:3), 'type', 'ppr',...
%         'nonorthogonal',nonorthogonal);
% else
%     proj=projaxes(u_to_rlu(1:3,1)', u_to_rlu(1:3,2)', u_to_rlu(1:3,3)', 'uoffset', u0(1:3), 'type', 'ppp',...
%         'nonorthogonal',nonorthogonal);
% end
