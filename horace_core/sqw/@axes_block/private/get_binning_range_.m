function bin_range = get_binning_range_(obj,cur_proj,new_proj)
% Get the default binning range to use in cut, which is defined by the new
% projection. If no new projection is provided, return current binning
% range.
%
% If new projection is not aligned with the old projection, the new
% projection binning is copied from the old projection binning according to
% axis number, i.e. if axis 1 of cur_proj had 10 bins, axis 1 of target 
% proj would have 10 bins, etc. 
%
% Inputs:
% obj      - current instance of the axes block
% cur_proj - the projection, current block is defined for. (may be empty)
% new_proj - the projection, for which the requested range should
%            be defined
% if both these projection are empty, returning the current binning range
%
% Output:
% bin_range - 3-element cellarray of ranges, containing current
%             binning range expressed in the coordinate system
%             defined by the new projection (or current binning range if new
%             projection is not provided)

% retrieve existing binning range
range = obj.img_range;
nsteps= obj.nbins_all_dims;
if ~isempty(cur_proj)
    % set up target projection for coordinate transformation to work
    cur_proj.targ_proj = new_proj;
    % convert ranges and step into target coordinate system
    full_range = expand_box(range(1,:),range(2,:));
    targ_range = cur_proj.from_this_to_targ_coord(full_range);

    % transformed 4D-range, compressed into min/max 4D-points
    range = [min(targ_range,[],2)';max(targ_range,[],2)'];
end
% extract binning descriptors, necessary for building the appropriate axes
% block, transferring the binning
bin_range = arrayfun(@build_binning,range(1,:),range(2,:),nsteps,'UniformOutput',false);

function bin_range = build_binning(min_range,max_range,nsteps)
%
if nsteps == 1% integration range
    bin_range = [min_range,max_range];
    return
end
step = (max_range-min_range)/(nsteps);
% axis binning parameters
bin_range = [min_range+step/2,step,max_range-step/2];