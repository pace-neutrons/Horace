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
if isempty(varargin)
    inputs = w1;
elseif iscell(varargin{1})
    if nargin > 2
        error('HORACE:combine_sqw:invalid_argument',...
            'if second argument is a cellarray of sqw objects, combine_sqw can only accept 2 arguments');
    end
    inputs = [w1,varargin{1}{:}];
else
    inputs = [w1,varargin{:}];
end

right_type = arrayfun(@(x) isa(x, 'sqw'), inputs);
if ~all(right_type)
    n_empty = numel(right_type)-sum(right_type);
    error('HORACE:combine_sqw:invalid_argument',...
        ['Input objects must be sqw type with detector pixel information.' ...
        ' Input contains %d non-sqw objects'],...
        n_empty);
end

% Ignore empty datasets
is_empty = arrayfun(@(x)(x.pix.num_pixels == 0),inputs);
inputs = inputs(~is_empty);

if isempty(inputs)
    wout = w1;
    return;

elseif isscalar(inputs)
    wout = copy(inputs);
    return;

end


% calculate real image ranges for all datasets. Transform the ranges into
% the coordinate frame of the first dataset
img_ranges = arrayfun(@(x) x.data.img_range,inputs,...
    'UniformOutput',false);
full_img_rng = cellfun(@(box) expand_box(box(1,:),box(2,:)),img_ranges,...
    'UniformOutput',false);

exper = arrayfun(@(sq)(sq.experiment_info),inputs,...
    'UniformOutput',false);
%
% retrieve projections for all contributing cuts
all_proj_block = arrayfun(@(ws) ws.data.proj,inputs,...
    'UniformOutput',false);

% transform the ranges into common coordinate system
full_pix_rng = cellfun(@(proj, data) proj.transform_img_to_pix(data),...
    all_proj_block,full_img_rng,'UniformOutput',false);


% do transformation into the first sqw object image coordinate frame
proj1 = all_proj_block{1};
full_img_rng = cellfun(@(data) proj1.transform_pix_to_img(data),...
    full_pix_rng,'UniformOutput',false);

full_img_rng = [full_img_rng{:}];
% get common range for combining pixels
combine_range = [min(full_img_rng,[],2),max(full_img_rng,[],2)]';
combine_range = range_add_border(combine_range);


% Extract binning from the first sqw object and extend this binning onto
% whole combine range:
new_range_arg = cell(1,4);
nbins = inputs(1).data.axes.nbins_all_dims;
paxis = nbins>1;
npax = 0;
for i=1:4
    new_range_arg{i} = combine_range(:,i)';
    if paxis(i)
        npax = npax+1;
        np   = nbins(i);
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
pix = arrayfun(@(x) x.pix, inputs, 'UniformOutput', false);

% Turn off horace_info output, but save for automatic clean-up on exit or ctrl-C
info_level = get(hor_config,'log_level');
cleanup_obj=onCleanup(@()set(hor_config, 'log_level', info_level));
set(hor_config,'log_level',-1);

% concatenate object pixels into single pixels blob
wout.pix = PixelDataBase.cat(pix{:});

% combine experiments from contributing files. Cut should drop duplicates
wout.experiment_info = exper{1}.combine_experiments(exper(2:end),true,true);


% completely break relationship between bins and pixels in memory and make
% all pixels contribute into single large bin.
ax = line_axes('nbins_all_dims', ones(4,1), 'img_range', combine_range);
wout.data = d0d(ax, proj1);
wout.data.npix = wout.pix.num_pixels;

wout=cut(wout, proj1, new_range_arg{:});
