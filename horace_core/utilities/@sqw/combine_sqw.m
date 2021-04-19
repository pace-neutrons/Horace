function wout=combine_sqw(w1,varargin)
% Combine two or more sqw objects in order to improve statistics
%
% Usage:
% wout=combine_sqw(w1,w2)
% wout=combine_sqw(w1,w2,w3,...,wN)
% or
% wout=combine_sqw(w1,{w2,w3,...,wN})
%
%  Note that all objects must be
% "true" sqw object, for which pixel information has been retained.
%
% The dimensionality of a cut will be defined by the dimensionality of the
% first sqw object,i.e. if first sqw object is 1D cut in h-direction,
% the result would be 1D cut in h direction.
% The cut ranges and integration ranges will be expanded to cover
% the range of all sqw objects to combine but the binning steps of the result
% are equal to the binning steps of the first combined sqw object.
%
% The most common case of combining is combining two sqw objects with
% similar geometry i.e. combination of two sqw objects which are the 1D
% cuts along x-axis made at different y-points
%
% Attempt to combine sqw objects with different lattices would work producing
% the object with the lattice of the first sqw object but the result would
% not have the physical meaning.
%
% The output object will have a combined value for the integration range
% e.g. combining two 2d slices taken at L=1 and L=2 will result in an
% output for which the stated value of L is L=1.5
%
% Sqw objects which use different projection axes can be combined. The
% output object will have the projection axes of the first object.
%
% RAE 21/1/10
%
% AB: 16/04/21 fully refactored using generic projection interface.
%
if nargin<2
    error('HORACE:combine_sqw:invalid_argument',...
        'routine needs at least two arguments');
end
%
if iscell(varargin{1})
    if nargin>2
        error('HORACE:combine_sqw:invalid_argument',...
            'if second argument is a cellarray of sqw objects, combine_sqw can only accept 2 arguments');
    end
    inputs = [w1,varargin{1}{:}];
else
    inputs = [w1,varargin{:}];
end
right_type = arrayfun(@(x)is_sqw_type(x),inputs);
if ~all(right_type)
    n_empty = numel(right_type)-sum(right_type);
    error('HORACE:combine_sqw:invalid_argument',...
        'Input objects must be sqw type with detector pixel information. Input contans %d objects without pixels',...
        n_empty);
end
% Ignore empty datasets
is_empty = arrayfun(@(x)(x.data.pix.num_pixels == 0),inputs);
if all(is_empty)
    wout= w1;
    return;
end

inputs = inputs(~is_empty);
if numel(inputs) == 1
    wout = copy(inputs(1));
    return;
end

%
% calculate real image ranges for all datasets. Transform the ranges into
% the coordinate frame of the first dataset
img_ranges = arrayfun(@(x)(x.data.img_db_range),inputs,...
    'UniformOutput',false);
full_img_rng = cellfun(@(box)(expand_box(box(1,:),box(2,:))),img_ranges,...
    'UniformOutput',false);
%
% retrieve projections for all contributing cuts
all_proj_block = arrayfun(@(ws)(ws.data.get_projection()),inputs,...
    'UniformOutput',false);
% transform the ranges into common coordinate system
full_pix_rng = cellfun(@(proj,data)(proj.transform_img_to_pix(data)),...
    all_proj_block,full_img_rng,'UniformOutput',false);
% remove offsets (offsets are in Crystal Cartesian (e.g. pix coordinates)
offsets = arrayfun(@(x)(x.data.uoffset),inputs,...
    'UniformOutput',false); % presumably in pix_ranges
full_pix_rng  = cellfun(@(range,offset)(range + repmat(offset,1,16)),...
    full_pix_rng,offsets,'UniformOutput',false);


% do transformation into the first sqw object image coordinate frame
proj1 = all_proj_block{1};
full_img_rng = cellfun(@(data)(proj1.transform_pix_to_img(data)),...
    full_pix_rng,'UniformOutput',false);

full_img_rng = [full_img_rng{:}];
% get common range for combining pixels
combine_range = [min(full_img_rng,[],2),max(full_img_rng,[],2)]';
combine_range = range_add_border(combine_range);

% Extract binning from the first sqw object and extend this binning onto
% whole combine range:
% TODO: refactor using future axes_block, extract common code with symmetrise_sqw
%
new_range_arg = cell(1,4);
paxis  = false(4,1);
paxis(inputs(1).data.pax) = true;
npax = 0;
for i=1:4
    new_range_arg{i} = combine_range(:,i)';
    if paxis(i)
        npax = npax+1;
        np = numel(inputs(1).data.p{npax});
        range = new_range_arg{i};
        dist = range(2)-range(1);
        if np>1
            step = dist/(np-1);
        else
            step = dist;
        end
        new_range_arg{i} = [range(1),step,range(2)];
    end
end
% combine pixels into single pixels block
wout = copy(inputs(1));
pixout = wout.data.pix;
for i=2:numel(inputs)
    pixout = PixelData.cat(pixout,inputs(i).data.pix);
end
wout.data.pix = pixout;


% Turn off horace_info output, but save for automatic clean-up on exit or cntrl-C
info_level = get(hor_config,'log_level');
cleanup_obj=onCleanup(@()set(hor_config,'log_level',info_level));
set(hor_config,'log_level',-1);

% completely break relationship between bins and pixels in memory and make
% all pixels contribute into single large bin.
% TODO: refactor and make applicable for file-based operations
%
wout.data.img_db_range = combine_range ;

wout.data.pax = 1:4;
wout.data.dax = 1:4;
wout.data.p  = arrayfun(@(i)(combine_range(:,i)),1:4,'UniformOutput',false);
wout.data.npix = wout.data.pix.num_pixels;
%
wout=cut(wout,proj1,new_range_arg{:});
