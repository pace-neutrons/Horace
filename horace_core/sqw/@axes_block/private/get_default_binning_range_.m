function range = get_default_binning_range_(obj,cur_proj,new_proj)
% get the default binning range to use in cut, defined by new
% projection
% Inputs:
% obj      - current instance of the axes block
% cur_proj - the projection, current block is defined for
% new_proj - the projection, for which the requested range should
%            be defined
% Output:
% range    - 4-element cellarray of ranges, containing current
%            binning range expressed in the coordinate system,
%            defined by the new projection

% convert existing binning range into set of 4-D vectors
range = zeros(2,4);
p = obj.p;
minmax = cellfun(@(x)([min(x);max(x)]),p);
range(:,obj.pax) = minmax;
range(:,obj.iax) = obj.iint;

% convert step into 4-D step vector (from 0-point)
step= zeros(1,4);
stepv = cellfun(@(r0,x)(x(2)-x(1)),p);
step(obj.pax) = stepv;
step(obj.iax) = obj.iint(2,:)-obj.iint(1,:);

% convert ranges and step into target coordinate system
full_range = expand_box(range(1,:),range(2,:));
cc_range = cur_proj.transform_img_to_pix(full_range);
cc_step  = cur_proj.transform_img_to_pix(step+range(1,:));

targ_range = new_proj.transform_pix_to_img(cc_range);
targ_step  = new_proj.transform_pix_to_img(cc_step);

% 4-D step vector;
range = [min(targ_range,[],1);max(targ_range,[],1)];
targ_step = targ_step-range(1,:);