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
% v1 and v2 are two vectors which lie in the plane of the reflection plane.
% v3 is a vector connecting the plane to the origin (i.e. specifies an
% offset).
%
% sym = SymopReflection([0,1,0],[0,0,1],[1,0,0]);
% e.g. wout=symmetrise_sqw(win, sym)
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
          'symmetrisation only implemented for single sqw object, not arrays of objects. Use a for-loop to deal with arrays');
end

if ~has_pixels(win)
    %what we should actually do here is go to the dnd-symmetrise function
    %of the correct dimensionality
    error('HORACE:symmetrise_sqw:invalid_argument', ...
          'input object must be sqw type with detector pixel information');
end

if numel(varargin) == 1 && isa(varargin{1}, 'Symop')

    sym = varargin{1};
elseif numel(varargin) == 3

    sym = SymopReflection(varargin{:});
else
    error('HORACE:symmetrise_sqw:invalid_argument', ...
          ['Call as:\n', ...
          'wout = symmetrise_sqw(win, sym)\n', ...
          'DEPRECATED wout = symmetrise_sqw(win,v1,v2,v3)']);
end

win = sqw(win);
wout = copy(win);

if isa(sym, 'SymopReflection')
    fold = numel(sym);
elseif isa(sym, 'SymopRotation')
    warning('HORACE:symmetrise_sqw:rotation', ...
            'SymopRotation support in symmetrise is currently experimental')

    % Don't need to do the 360 mapping (last == ID)
    fold = (360 / sym.theta_deg) - 1;

    if numel(sym) ~= 1
        error('HORACE:symmetrise_sqw:invalid_argument', ...
              'Rotational symmetry only possible for single rotation')
    end

    if floor(fold) ~= fold
        error('HORACE:symmetrise_sqw:invalid_argument', ...
              ['Rotation must be an n-fold mapping onto the full circle.\n', ...
               'Fold : %1.3f'], fold+1)
    end

    sym = repmat(sym, fold, 1);

else
    error('HORACE:symmetrise_sqw:not_implemented', ...
          'Symmetrise does not currently support %s', class(sym))
end

if wout.pix.is_filebacked

    wout = wout.get_new_handle();
    for i = 1:win.pix.num_pages
        [wout.pix, curr_page] = wout.pix.load_page(i);
        for i = 1:fold
            sel = ~sym(i).in_irreducible(curr_page(1:3, :));
            curr_page(1:3, sel) = sym(i).transform_vec(curr_page(1:3, sel));
        end
        wout.pix.format_dump_data(curr_page);
    end
    wout = wout.finalise();

else

    for i = 1:fold
        sel = ~sym(i).in_irreducible(wout.pix.q_coordinates);
        wout.pix.q_coordinates(:, sel) = sym(i).transform_vec(wout.pix.q_coordinates(:, sel));
    end

end


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
    cross_points = box_intersect(cc_ranges, ...
                                 [sym.u+sym.offset,sym.v+sym.offset,sym.offset]);

    % and combine all them together
    cc_exist_range = [cc_ranges,cross_points];

    % transform existing range into transformed range
    for i = 1:fold
        idx = ~sym(i).in_irreducible(cc_exist_range);
        cc_exist_range(:,idx) = sym(i).transform_vec(cc_exist_range(:,idx));
    end
elseif isa(sym, 'SymopRotation')

end
img_box_points = proj.transform_pix_to_img(cc_exist_range);
img_db_range_minmax = [min(img_box_points,[],2),max(img_box_points,[],2)]';

% add fourth dimension to the range
all_sym_range = [img_db_range_minmax,existing_range(:,4)];

% Extract existing binning: TODO: refactor using future ortho_axes, extract
% common code with combine_sqw

new_range_arg = cell(1,4);
paxis = false(4,1);
paxis(wout.data.pax) = true;
npax = 0;
for i=1:4
    new_range_arg{i} = all_sym_range(:,i)';
    if paxis(i)
        npax = npax+1;
        is_proj_axis = numel(wout.data.p{npax}) > 1;
        range = new_range_arg{i};
        dist = range(2)-range(1);
        if is_proj_axis
            step = wout.data.p{npax}(2) - wout.data.p{npax}(1);
            % Ranges are bin-centres
            new_range_arg{i} = [range(1), step, range(2)];
        else
            new_range_arg{i} = range
        end
    end
end

% Turn off horace_info output, but save for automatic clean-up on exit or cntrl-C (TGP 30/11/13)
cleanup_obj = set_temporary_config_options(hor_config, 'log_level', -1);

% completely break relationship between bins and pixels in memory and make
% all pixels contribute into single large bin
ax = wout.data.axes;
proj = wout.data.proj;

ax.do_check_combo_arg = false;
ax.img_range = all_sym_range;
ax.nbins_all_dims = ones(1,4);
ax.do_check_combo_arg = true;
ax = ax.check_combo_arg();
dat = DnDBase.dnd(ax,proj,0,0,sum(wout.data.npix(:)));
wout.data = dat;

wout = cut(wout,proj,new_range_arg{:});

end
