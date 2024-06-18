function [the_range,is_in,img_targ_center] = get_targ_range(obj,source_proj,targ_proj,range_requested)
% Identify range this axes block occupies in target coordinate
% system.
%
% Inputs:
% obj           -- initialized axes block object containing its ranges
% source_proj   -- aProjectionBase class, describing coordinate system of
%                  the current axis block
% targ_proj     -- aProjectionBase class, describing coordinate system of
%                  target axes block, where target coordinate range should
%                  be calculated.
% Optional:
% range_requested
%               -- logical 4-element array, containing true, for the
%                  coordinates, which are requested and false for which are
%                  not. If omitted, all elements of this are set true, so
%                  all ranges are requested.
%
% Output:
% the_range     --  2x4 element array containing min/max ranges, current
%                   axes block range (obj.img_range) occupies in the target
%                   coordinate system.
%                   If range_requested is provided,
% is_in         --  true, if centre of target range lies withing the ranges
%                   of the source data.
% img_targ_center
%              --   the centre of the target range in the source coordinate
%                   system
if nargin<4
    range_requested = true(1,4);
end

if ~exist('targ_proj','var') || isempty(targ_proj)
    % getting binning range which present in the existing axes_block
    the_range = obj.img_range;
    return
end

if isstruct(targ_proj) % allow input to be a structure
    if serializable.is_serial_struct(targ_proj)
        targ_proj = serializable.from_struct(targ_proj);
    else
        op = line_proj();
        targ_proj = op.from_bare_struct(targ_proj);
    end
end
if ~targ_proj.alatt_defined
    targ_proj.alatt = source_proj.alatt;
end
if ~targ_proj.angdeg_defined
    targ_proj.angdeg = source_proj.angdeg;
end
%
% cross-assign appropriate projections to allow
% "from_this_to_targ_coord" method and possible optimizations in
% source->target target->source transformations

source_proj.targ_proj = targ_proj;
targ_proj.targ_proj   = source_proj;


% can we deploy simple case of linear projections or curvelinear
% projections with the same centre?
current_range = obj.img_range;
offset_diffr = source_proj.offset - targ_proj.offset;
if targ_proj.do_3D_transformation
    is_zero_off  = any(abs(offset_diffr(1:3))<eps('single'));
else
    is_zero_off  = any(abs(offset_diffr)<eps('single'));
end

img_targ_center = source_proj.transform_hkl_to_img(targ_proj.offset(1:3)');
is_in           = obj.in_range(img_targ_center);

if isa(source_proj,class(targ_proj)) && (is_zero_off || isa(source_proj,'LineProjBase'))
    % if both projections relate to the same type of coordinate system,
    % the min/max range evaluation will be trivial
    full_range = expand_box(current_range(1,:),current_range(2,:));
    full_targ_range = source_proj.from_this_to_targ_coord(full_range);
    the_range = min_max(full_targ_range)';
else
    % if not, analyse cut hull to understand what ranges can be
    % specified. This else brings together all curvilinear projections
    % and uses the fact that first coordinate of these coordinate
    % system changes from 0 to inf.
    the_range = search_for_range(obj,source_proj,targ_proj,is_in,range_requested);
end


%
function out_range = search_for_range(obj,source_proj,targ_proj,in_ranges,ranges_requested)
% find the maximal range, the current grid occupies in target coordinate
% system
%
range_defined  = false(2,4);
out_range     = repmat([-inf;inf],1,4);
img_range = obj.img_range;
switch in_ranges
    case -1
        nbins_per_dim = ones(1,4);

        max_out_range = out_range;
    case 0
        nbins_per_dim = 10*ones(1,4);
        max_out_range = out_range;
        % caclculations show that only spherical or cylindrical projection
        % may come here. Bad for some stray projection in a future
        if isa(targ_proj,'CurveProjBase')
            max_out_range(1,1) = 0;
            range_defined(1,1) = true;
        end
    case 1 % Center is inside of the hull surrounding the data
        nbins_per_dim = 10*ones(1,4);

        taxes         = feval(targ_proj.axes_name);
        taxes.type    = targ_proj.type;
        max_out_range = taxes.max_img_range;
        range_defined = ~isinf(max_out_range);
end
%
if source_proj.do_3D_transformation
    range_defined   = range_defined(:,1:3);
    out_range(:,4)  = img_range(:,4); % dE range is orthogonal to others and is not transformed
    img_range       = img_range(:,1:3);
    nbins_per_dim   = nbins_per_dim(1:3);
    max_out_range   = max_out_range(:,1:3);
    ranges_requested= ranges_requested(1:3);
end
range_known = all(range_defined,1);
if ~any(ranges_requested(~range_known))
    return;
end

range0 = transf_range(source_proj,img_range,nbins_per_dim,range_defined,max_out_range);
difr = 1;
ic   = 1;
while difr>1.e-3 && ic <= 5 % node multiplier doubles number of points
    % on each iteration step and goes 2,4,8,16,32. As the number of points increases on the hull,
    % it is still not too big number so memory requests are acceptable.
    nbins_per_dim   = nbins_per_dim*2;
    range = transf_range(source_proj,img_range,nbins_per_dim,range_defined,max_out_range);
    difr = calc_difr(range0,range);
    range0 = range;
    ic = ic+1;
end
if ic > 5 && difr>1.e-3
    warning('HORACE:get_targ_range',[ ...
        ' target range search algorithm have not converged after 5 iterations.\n', ...
        ' Search have identified the following default range:\n%s\n',...
        ' This range may be inaccurate'],disp2str(range))
end
%
if source_proj.do_3D_transformation
    out_range(:,1:3) = range;
end

function loc_range = transf_range(source_proj,img_range,nbins_all_dims,range_defined,out_range)
% transfer axes hull into target coordinate system.

shell = build_hull(img_range,nbins_all_dims);

shell_transf = source_proj.from_this_to_targ_coord(shell);

loc_range = min_max(shell_transf)';
if any(range_defined(:))
    loc_range(range_defined) =out_range(range_defined);
end

function difr = calc_difr(range0,range)
% calculate maximal difference between two ranges
min_difr = max(-(range(1,:)-range0(1,:)));
max_difr = max((range(2,:)-range0(2,:)));
difr     = max(min_difr,max_difr);
