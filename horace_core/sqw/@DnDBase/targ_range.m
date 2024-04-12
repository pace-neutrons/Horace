function the_range = targ_range(obj,targ_proj,varargin)
%TARG_RANGE calculate the full range of the image to be produced by target
% projection from the current image,
%
% Inputs:
% obj        -- dnd object - source of image ranges to process
% targ_proj  -- aProjectionBase class which defines target coordinate
%               system where the range should be identified.
% Optional:
%  ranges_requested
%            -- four element logical array, where true states the requested
%               range to identify. This is used for identifying the ranges
%               of orthogonal dimensions (i.e. dE so that if only
%
% '-binning' if present, the method returns range as cellarray of binning
%            parameters, i.e. the parameters which you would provide to cut
%            to get the target cut in the ranges produced
% Output:
% range     -- 2x4 element array of min-max ranges, the ranges of the input
%              object will occupy in the target coordinate system.
%              if "-binning" is requested, this range is transformed into 4
%              element cellarray, where each cell contains binning
%              parameters in the form which provides initial binning range
%
%             when range_requested for an element of binning range is
%             false, the range for this element is [-inf;inf] or corresponding
%             cell in "-binning" mode is empty.
%
%
[ok,mess,do_binning_range,argi] = parse_char_options(varargin,'-binning');
if ~ok
    error('HORACE:DnDBase:invalid_argument',mess);
end
if isempty(argi)
    ranges_requested = true(1,4);
else
    ranges_requested = logical(argi{1});
    if numel(ranges_requested) ~= 4
        error('HORACE:DnDBase:invalid_argument',...
            'Requested range array needs to 4 elements. Actually, its size is :%s',...
            disp2str(size(range_requested)));
    end
end
the_range = repmat([-inf;inf],1,4);
if ~exist('targ_proj','var') || isempty(targ_proj)
    % getting binning range which produced existing DnD object
    the_range(:,ranges_requested) = obj.img_range(:,ranges_requested);
else
    source_proj = obj.proj;
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
    cur_range = obj.img_range;
    offset_diffr = source_proj.offset - targ_proj.offset;
    if targ_proj.do_3D_transformation
        is_zero_off  = any(abs(offset_diffr(1:3))<eps('single'));
    else
        is_zero_off  = any(abs(offset_diffr)<eps('single'));
    end

    if isa(source_proj,class(targ_proj)) && (is_zero_off || isa(source_proj,'LineProjBase'))
        % if both projections relate to the same type of coordinate system,
        % the min/max range evaluation will be trivial
        full_range = expand_box(cur_range(1,:),cur_range(2,:));
        full_targ_range = source_proj.from_this_to_targ_coord(full_range);
        range = min_max(full_targ_range)';
    else
        % if not, analyse cut hull to understand what ranges can be
        % specified
        targ_center = source_proj.transform_hkl_to_img(targ_proj.offset(:));
        is_in       = in_range(cut_range,targ_center);

        range = search_for_range(obj,source_proj,is_in,ranges_requested);
    end
    the_range(:,ranges_requested) = range(:,ranges_requested);
end
if do_binning_range
    nsteps = obj.axes.nbins_all_dims;
    the_range  = arrayfun(@build_binning,the_range(1,:),the_range(2,:),nsteps,'UniformOutput',false);
end

function bin_range = build_binning(min_range,max_range,nsteps)
% simple procedure to convert img_range into binning parameters
if isinf(min_range)
    bin_range = [];
    return;
end

if nsteps == 1% integration range
    bin_range = [min_range,max_range];
    return
end
step = (max_range-min_range)/(nsteps);
% axis binning parameters
bin_range = [min_range+step/2,step,max_range-step/2];

function out_range = search_for_range(obj,source_proj,in_ranges,ranges_requested)
% find the maximal range, the current grid occupies in target coordinate
% system
%
%

out_range = repmat([-inf;inf],1,4);
nbins_per_dim = 10*ones(1,4);
img_range = obj.axes.img_range;
range0 = transf_range(source_proj,img_range,nbins_per_dim);
if source_proj.do_3D_transformation
    out_range(:,4) = range0(:,4); % dE range is orthogonal to others and is not transformed
    img_range = img_range(:,1:3);
    nbins_per_dim = nbins_per_dim(1:3);
    range0    = range0(:,1:3);
end
if sum(ranges_requested) == 1 && ranges_requested(4)
    return;
end
difr = 1;
ic   = 1;
while difr>1.e-3 && ic <= 5 % node multiplier doubles number of points
    % on each iteration step and goes 2,4,8,16,32. As the number of points increases on the hull,
    % it is still not too big number so memory requests are acceptable.
    nbins_per_dim   = nbins_per_dim*2;
    range = transf_range(source_proj,img_range,nbins_per_dim);
    difr = calc_difr(range0,range);
    range0 = range;
    ic = ic+1;
end
if ic > 5 && difr>1.e-3
    warning('HORACE:targ_range', ...
        ['target range search algorithm have not converged after 5 iterations.\n', ...
        ' The default range identified for the cut may be inaccurate'])
end
%
if source_proj.do_3D_transformation
    out_range(:,1:3) = range;
end

function loc_range = transf_range(source_proj,img_range,nbins_all_dims)
% transfer axes hull into target coordinate system.

shell = build_hull(img_range,nbins_all_dims);

shell_transf = source_proj.from_this_to_targ_coord(shell);
loc_range = min_max(shell_transf)';

function difr = calc_difr(range0,range)
% calculate maximal difference between two ranges
min_difr = max(-(range(1,:)-range0(1,:)));
max_difr = max((range(2,:)-range0(2,:)));
difr     = max(min_difr,max_difr);
