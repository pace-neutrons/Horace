function [ind_range,ind_en,u_to_rlu]=get_projection_from_pbin_inputs_(ndim,varargin)
% Parce binning inputs and try to guess some u_to_rlu from them
% 
% NOT UNIT TESTED. Usage unknown -- very complicated. Leave for the time
% being but remove after some efforts
%
% Outputs:
% ind_range index to the range in the input argument list (may permute the projection axes)
% ind_en    -- the position of the energy axis among input arguments
% u_to_rlu  -- some form of transformation from Crystal Cartesian to rly
%             (very constrained, not general)
%
% Get the vectors and binning for plot axes
u_to_rlu = zeros(4,4);
for i=1:ndim
    urlu=varargin{2*i};
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
