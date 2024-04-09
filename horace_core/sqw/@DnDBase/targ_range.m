function range = targ_range(obj,targ_proj,varargin)
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
if ~exist('targ_proj','var') || isempty(targ_proj)
    % getting binning range which produced existing DnD object
    range = obj.img_range;
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
    % cross-assign appropriate projections to enable possible optimizations
    source_proj.targ_proj = targ_proj;
    targ_proj.targ_proj   = source_proj;

    if isa(source_proj,class(targ_proj))
        % if both projections relate to the same coordinate system, the min/max
        % evaluation will be sufficient
        cur_range = obj.img_range;
        full_range = expand_box(cur_range(1,:),cur_range(2,:));
        full_targ_range = source_proj.from_this_to_targ_coord(full_range);
        range = [min(full_targ_range,[],2),max(full_targ_range,[],2)]';
    else
        % if not, analyse cut hull to understand what ranges can be
        % specified
        range = search_for_range(obj,source_proj,ranges_requested);
    end
end
if do_binning_range
    nsteps = obj.axes.nbins_all_dims;
    range  = arrayfun(@build_binning,range(1,:),range(2,:),nsteps,'UniformOutput',false);
end

function bin_range = build_binning(min_range,max_range,nsteps)
% simple procedure which convert range into binning parameters
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

function range = search_for_range(obj,source_proj,ranges_requested)
% find the maximal range, the current grid occupies in target coordinate
% system
%
% The most primitive and pretty memory expensive search algorithm possible.
%
range = repmat([-inf;inf],1,4);
[range0,dE_range] = transf_range(obj,source_proj,1);
if source_proj.do_3D_transformation
    range(:,4) = dE_range;
end
if sum(ranges_requested) == 1 && ranges_requested(4)
    return;
end
difr = 1;
node_mult = 2;
while difr>1.e-3 && node_mult<33 % node multiplier doubles number of points
    % on each iteration step and goes 2,4,8,16,32. As the number of points increases on the hull,
    % it is still not too big number so memory requests are acceptable.
    range = transf_range(obj,source_proj,node_mult);
    difr = calc_difr(range0,range);
    range0 = range;
    node_mult = node_mult*2;
end
if node_mult > 32
    warning('HORACE:targ_range', ...
        ['target range search algorithm have not converged after 5 iterations.\n', ...
        ' The default range identified for the cut may be inaccurate'])
end
%
if source_proj.do_3D_transformation
    range  = [range,dE_range];
end

function [loc_range,dE_range] = transf_range(obj,source_proj,multiplier)
% transfer axes hull into target coordinate system.
if source_proj.do_3D_transformation
    shell = obj.axes.get_bin_nodes('-3D','-hull',multiplier);
    dE_range = obj.axes.img_range(:,4);
else
    shell = obj.axes.get_bin_nodes('-hull',multiplier);
    dE_range = [];
end
shell_transf = source_proj.from_this_to_targ_coord(shell);
loc_range = min_max(shell_transf)';

function difr = calc_difr(range0,range)
% calculate maximal difference between two ranges
min_difr = max(-(range(1,:)-range0(1,:)));
max_difr = max((range(2,:)-range0(2,:)));
difr     = max(min_difr,max_difr);
