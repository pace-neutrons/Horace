function obj = spinw_dnd_obj_constructor_(lattice_const,varargin)
% build dnd object from list of input parameters usually
% defined by spinW
% Inputs:
% lattice_const -- 6-element array containing 3 components for
%                  lattice parameters and 3 components for
%                  lattice angles
% Optional:
% 0 to 4 pairs containing [axis direction, binning parameters]
% where
% axis_direction -- 4-element vector containing axis direction
%                   in hklE coordinate system
% binning parameters
%                -- 3-element vector contaning min,step,max
%                   binning parameters for appropriate axis
%
% Number of pairs would define number of dimensions in DnD object
% The constructor build object containing line_proj.
%
if nargin == 1
    proj = line_proj('alatt',lattice_const(1:3),'angdeg',lattice_const(4:end));
    ax   = line_axes(0);
    obj = d0d(ax,proj);
    return;
end
nargi = numel(varargin);
if nargi > 8 || rem(nargi,2) ~= 0
    error('HORACE:DnDBase:invalid_argument', ...
        'Number of binning paramerets in DnD-spinW constructor can not exceed 8 and have to be even or 0. It is: %d', ...
        nargi);
end
uvw = cell(1,3);
i=1:4;
binning    = arrayfun(@(i)[0,0],i,'UniformOutput',false);
uvw_idx = 0;
for i=1:floor(nargi/2)
    i_dir = 2*(i-1)+1; % may go up to 7
    dir = varargin{i_dir};
    bin = varargin{i_dir+1};
    if dir(4)> 0
        if any(dir(1:3)~=0)
            error('HORACE:DnDBase:invalid_argument', ...
                'Energy dimension have to be orthogonal to any other dimension. It is: "%s"',...
                disp2str(dir));
        end
        binning{4} = bin;
    else
        uvw_idx  = uvw_idx +1;
        uvw{uvw_idx}     = dir(1:3);
        binning{uvw_idx} = bin;
    end
end
if isempty(uvw{1})
    uvw{1} = [1,0,0];
end
if isempty(uvw{2})
    v([2,3,1]) = uvw{1}; % do cyclical shift of parameters
    uvw{2} = v;
end
proj = line_proj(uvw{:},'alatt',lattice_const(1:3),'angdeg',lattice_const(4:end));
ax   = line_axes(binning{:});
obj  = DnDBase.dnd(ax,proj);