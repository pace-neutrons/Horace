function bin_range = get_default_binning_range_(obj,img_db_range,cur_proj,new_proj)
% get the default binning range to use in cut, defined by new
% projection.
%
% If new projection is not aligned with the old projection, the new
% projection binning is copied from old projection binning according to
% axis, i.e. if axis 1 of cur_proj had 10 bins, axis 1 of target proj would
% have 10 bins, etc. 
%
% Inputs:
% obj      - current instance of the axes block
% img_db_range -- the range pixels are binned on and the current binning is
%            applied
% cur_proj - the projection, current block is defined for
% new_proj - the projection, for which the requested range should
%            be defined
% Output:
% range    - 4-element cellarray of ranges, containing current
%            binning range expressed in the coordinate system,
%            defined by the new projection

% convert existing binning range into set of 4-D vectors
range = img_db_range;

% Calculate number of steps in each axis direction, to transfer these
% numbers into steps in other directions
nsteps = zeros(4,1);
p = obj.p;
naxis_step = cellfun(@(x)(numel(x)-1),p);
nsteps(obj.pax) = naxis_step;
nsteps(obj.iax) = 1;

% convert ranges and step into target coordinate system
full_range = expand_box(range(1,:),range(2,:));
%
targ_range = cur_proj.convert_to_target_coord(new_proj,full_range);

% transformed 4D-range
range = [min(targ_range,[],2)';max(targ_range,[],2)'];
% extract binning descriptors, necessary for building appropriate axes
% block, transferring the binning
bin_range = arrayfun(@build_binning,range(1,:)',range(2,:)',nsteps,'UniformOutput',false);

function bin_range = build_binning(min_range,max_range,nsteps)
%
if nsteps == 1% integration range
    bin_range = [min_range,max_range];
    return
end
step = (max_range-min_range)/(nsteps-1);
% axis parameters
bin_range = [min_range,step,max_range];