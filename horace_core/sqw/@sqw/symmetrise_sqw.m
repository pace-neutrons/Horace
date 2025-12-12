function wout=symmetrise_sqw(win,varargin)
% Symmetrise sqw dataset according to symop.
%
% v1,v2,v3 interface is deprecated and provided for backwards compatibility only
%
% wout = symmetrise_sqw(win, sym)
% DEPRECATED wout = symmetrise_sqw(win,v1,v2,v3)
%
% WORKS ONLY FOR DATA OBJECTS OF SQW-TYPE (I.E. WITH PIXEL INFO RETAINED).
%
% sym
%     Symmetry operation over which to reduce data
%       For reflections this is an array of SymopReflections
%          which are applied in sequence taking the values
%          for which coords'*cross(u, v) > 0
%          reducing the data onto the minimal set
%       For rotations this is a single SymopRotation
%          which will apply 360/theta_deg rotations
%          to reduce data into the positive quadrant
%          ** N.B. ** 360/theta_deg MUST be integral
%
% proj
%    Projection used for rotational reduction
%
%    Symmetrisation affects pixels in HKL and should take place in
%    orthogonal basis even if the projection is not.
%
% v1 and v2 are two vectors which lie in the plane of the reflection plane.
% v3 is a vector connecting the plane to the origin (i.e. specifies an
% offset).
%
% sym = SymopReflection([0,1,0],[0,0,1],[1,0,0]);
% e.g. wout=symmetrise_sqw(win, sym, proj)
% The object win is symmetrised in the plane specified by [0,1,0] and
% [0,0,1] (i.e a mirror plane which reflects [-1,0,0] on to [1,0,0]). v3
% is [1,0,0], so the plane is offset from the origin. This means that
% [-1,0,0] --> [3,0,0] etc.
%

%Modified by RAE 30/11/12 to account for possibility of non-orthogonal
%lattice (bug in previous incarnation of the code).

%Further modifications (with thanks to Marek Pikulski of ETHZ) to reduce memory load
%and decrease execution time

%==============================
%Some checks on the inputs:

if numel(win) ~= 1
    error('HORACE:symmetrise_sqw:invalid_argument', ...
        ['symmetrisation only implemented for single sqw object, ' ...
        'not arrays of objects. Use a for-loop to deal with arrays']);
end

if ~has_pixels(win)
    %what we should actually do here is go to the dnd-symmetrise function
    %of the correct dimensionality
    error('HORACE:symmetrise_sqw:invalid_argument', ...
        'input object must be sqw type with detector pixel information');
end

if isa(varargin{end}, 'aProjectionBase')
    % Projection under which transformation takes place (HKL).
    transf_proj = varargin(end);
    varargin = varargin(1:end-1);

    if transf_proj{1}.nonorthogonal
        error('HORACE:symmetrise_sqw:invalid_argument', ...
            'Cannot symmetrise to non-orthogonal projection');
    end

else
    % Also projection under which transformation takes place (HKL [orthogonal, so 90, 90, 90]).
    % alatt, however, is retained as the symmetrisation should not rescale.
    transf_proj = {line_proj([1 0 0], [0 1 0], ...
        'alatt', win.data.proj.alatt, ...
        'angdeg', [90, 90, 90])};
end


if isscalar(varargin) && isa(varargin{1}, 'Symop') || ...
        (iscell(varargin{1}) && all(cellfun(@(x) isa(x, 'Symop'), varargin{1})))

    sym = varargin{1};
elseif numel(varargin) == 3
    warning('HORACE:symmetrise_sqw:deprecated', ...
        'Passing vectors to symmetrise_sqw is deprecated, please use "Symop"');
    sym = SymopReflection(varargin{:});
else
    error('HORACE:symmetrise_sqw:invalid_argument', ...
        ['Call as:\n', ...
        'wout = symmetrise_sqw(win, sym)\n', ...
        'DEPRECATED wout = symmetrise_sqw(win,v1,v2,v3)']);
end

win = sqw(win);
wout = copy(win);

[sym, fold] = validate_and_generate_sym(sym);
% double wrapped cellarray
transforms = @sym.transform_pix;
% Need the projections to be wrapped in a cell array to be duplicated
% for each symmetry operation we're applying, since the first cell array
% may be unwrapped as an argument if 1 arg (as in this case), need
% double wrapped cellarray
wout.pix = wout.pix.apply(transforms, {{transf_proj(:)}}, false);

%=========================================================================
% Transform Ranges:
%
% Get image range:
% image range
existing_range = wout.data.img_range;
proj = win.data.proj;

% expand img_box into whole box and transform image range into pix range
exp_range = expand_box(existing_range(1,1:3), existing_range(2,1:3));
cc_ranges = proj.transform_img_to_pix(exp_range);

% identify intersection points between the image range and the symmetry plane
if isa(sym, 'SymopReflection')
    cc_exist_range = cc_ranges;
    for i = 1:fold
        cross_points = box_intersect(cc_ranges, ...
            [sym(i).u+sym(i).offset,sym(i).v+sym(i).offset,sym(i).offset]);
        % and combine all them together
        cc_exist_range = [cc_exist_range,cross_points];
    end

    for i = 1:fold
        % transform existing range into transformed range
        idx = ~sym(i).in_irreducible(cc_exist_range);
        cc_exist_range(:,idx) = sym(i).transform_vec(cc_exist_range(:,idx));
    end
else
    % 
    rot_center = sym.offset; % offset in Crystal Cartesian though should
    %  be hkl
    cc_exist_range = sym.transform_pix([cc_ranges,rot_center]);
end

img_box_points      = proj.transform_pix_to_img(cc_exist_range);
img_db_range_minmax = min_max(img_box_points)';

% add fourth dimension to the range
all_sym_range = [img_db_range_minmax,existing_range(:,4)];


% Turn off horace_info output, but save for automatic clean-up on exit or cntrl-C (TGP 30/11/13)
oll = get(hor_config, 'log_level');
set(hor_config, 'log_level', -1);
cleanup_obj = onCleanup(@()set(hor_config, 'log_level', oll));

% Build target object from symmetry-modified pixels and new data range
dat = wout.data;
% use symmetry-modified binning range and add border to mitigate possible
% round-off errors appeared when ranges were calculated. This will cause 
% gen_sqw with symmeterise_sqw(SymopIdentity) to produce slightly different
% result wrt. gen_sqw without transformation as binning ranges are different
% but will be compensating but not loosing boundary pixels in more physically
% interesting situations
if isa(sym,'SymopIdentity')
    dat.axes.img_range = all_sym_range;    
else
    dat.axes.img_range(:,1:3) = range_add_border(all_sym_range(:,1:3),-eps("single"));    
end
dat.s    = 0;
dat.e    = 0;
dat.npix = 0;

proj = dat.proj;
% unique_id is needed to call sort pixels inside routine
[dat.npix,dat.s,dat.e,pix,unique_id] = ...
    proj.bin_pixels(dat.axes,wout.pix,dat.npix,dat.s,dat.e);
[dat.s, dat.e] = normalize_signal(dat.s, dat.e, dat.npix);
wout.data = dat;
wout.pix = pix;
end
