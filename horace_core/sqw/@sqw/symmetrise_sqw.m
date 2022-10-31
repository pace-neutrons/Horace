function wout=symmetrise_sqw(win,v1,v2,v3)
% Symmetrise sqw dataset in the plane specified by the vectors v1, v2, and
% v3.
% wout=symmetrise_sqw(win,v1,v2,v3)
%
% WORKS ONLY FOR DATA OBJECTS OF SQW-TYPE (I.E. WITH PIXEL INFO RETAINED).
%
%
% v1 and v2 are two vectors which lie in the plane of the reflection plane.
% v3 is a vector connecting the plane to the origin (i.e. specifies an
% offset).
%
% e.g. wout=symmetrise_sqw(win,[0,1,0],[0,0,1],[1,0,0])
% The object win is symmetrised in the plane specified by [0,1,0] and
% [0,1,0] (i.e a mirror plane which reflects [-1,0,0] on to [1,0,0]). v3
% is [1,0,0], so the plane is offset from the origin. This means that
% [-1,0,0] --> [3,0,0] etc.
%

%Modified by RAE 30/11/12 to account for possibility of non-orthogonal
%lattice (bug in previous incarnation of the code).

%Further modifications (with thanks to Marek Pikulski of ETHZ) to reduce memory load
%and decrease execution time

%==============================
%Some checks on the inputs:
win=sqw(win);
wout = copy(win);

%New code (problem spotted by Matt Mena for case when using a single
%contributing spe file):
header = win.experiment_info;

if numel(win)~=1
    error('HORACE:symmetrise_sqw:invalid_argument', ...
        'symmetrisation only implemented for single sqw object, not arrays of objects. Use a for-loop to deal with arrays');
end

if ~has_pixels(win)
    %what we should actually do here is go to the dnd-symmetrise function
    %of the correct dimensionality
    error('HORACE:symmetrise_sqw:invalid_argument', ...    
    'input object must be sqw type with detector pixel information');
end

if numel(v1)~=3 || numel(v2)~=3 || numel(v3)~=3
    error('HORACE:symmetrise_sqw:invalid_argument', ...    
    'the vectors v1, v2 and v3 must all have 3 elements');
end

if all(size(v1)==[3,1])
    v1=v1';
end
if all(size(v2)==[3,1])
    v2=v2';
end
if all(size(v3)==[3,1])
    v3=v3';
end


%========================

%Get B-matrix and reciprocal lattice vectors and angles
s1 = header.samples{1};
alatt=s1.alatt;
angdeg=s1.angdeg;

[b, arlu, angrlu, mess] = bmatrix(alatt, angdeg);

if ~isempty(mess)
    error('Problem in symmetrisation - sqw object does not have valid alatt and/or angdeg fields');
end


% The first 3 rows of the pix array specify the co-ordinates in Q of each
% contributing detector pixel. The reference frame for the pix array is
% given by an orthonormal set of vectors found as the columns of
% the win.header.u_to_rlu. The x/y/z components of the vectors u are defined
% as follows:
% x is parallel to a*
% y is in the plane of a* and b* (perpendicular to x), with positive
% component along b*
% z is the cross-product of x and y.
%
% The vector win.header.uoffset is specified in terms of h,k,l (i.e. its
% components are along a*, along b* and along c*, so it is NOT specified in
% an orthonormal frame).

% First step, therefore, is to work out what is the reflection matrix in
% the orthonormal frame specified by u_to_rlu.

uconv=header.expdata(1).u_to_rlu(1:3,1:3);

%
%convert the vectors specifying the reflection plane from rlu to the
%orthonormal frame of the pix array:
% do not rely on the shift of the image to define symmetry plane.
%
% There are currently no situation when header would have offset.
% if it does have it, it should be utilized here.
%vec1=uconv\(v1'-header.uoffset(1:3));
%vec2=uconv\(v2'-header.uoffset(1:3));
% the symmetry plane should be defined in real hkl, not shifted hkl the
% image may be expressed in.
vec1=uconv\(v1');
vec2=uconv\(v2');

%Normal to the plane, in the frame of pix array (crystal Cartesian):
normvec=cross(vec1,vec2);

%Construct the reflection matrix in frame of pix array:
Reflec=zeros(3,3);%initialise reflection matrix
for i=1:3
    for j=1:3
        if i==j
            delt=1;
        else
            delt=0;
        end
        Reflec(i,j)=delt - (2 * normvec(i) .* normvec(j))./(sum(normvec.^2));
    end
end

%Coordinates of detector pixels, in the frame discussed above
coords=@() win.data.pix.q_coordinates; % MP: emulate a pointer / lazy data copy


%Note that we allow the inclusion of an offset from the origin of the
%reflection plane. This is specified in rlu.
%vec3=uconv\(v3'-header.uoffset(1:3));
vec3=uconv\(v3');
%Ensure v3 is a column vector:
if all(size(vec3)==[1,3])
    vec3=vec3';
end

%Translate the pixel co-ords by v3:
coords_new=bsxfun(@minus, coords(), vec3); % MP: favor bsxfun(@minus, A, B) over A-repmat(B)

%What we want to do now is to replace elements of the pix array whose
%coordinates are on one side of the plane with coords_refl, but not replace the elements on
%the other side of the reflection plane.

%Can determine which side of the plane a given point is on by taking the
%dot product of the normal and the coordinate of the point relative to some
%position in the plane.

side_dot=coords_new'*normvec; % MP: vector of scalar products, w/o repmat/bsxfun

% MP: (TODO) mem usage of the following could be reduced further by making it work
% in-place (the Reflec*... part created a temporary)
idx = find(side_dot > 0);
coords_new(:, idx) = Reflec*coords_new(:, idx); % MP: (TODO) could potentially be optimized further
clear 'side_dot'; % MP: not needed any more

coords_new=bsxfun(@plus, coords_new, vec3); % MP
%
% Clear existing pages range not to extend new range with existing.
% Take care if this method is extended to file-based data -- needs careful
% thinking
wout.data.pix.set_range(PixelData.EMPTY_RANGE_);
wout.data.pix.q_coordinates=coords_new;
% real pix range, calculated at the assignment of new coordinates to the
% pixels coordinates
clear 'coords_new';

%=========================================================================
% Transform Ranges:
%
% Get image range:
% image range
existing_range = wout.data.img_db_range;
proj = win.data.get_projection();

% expand img_box into whole box and transform image range into pix range
exp_range= expand_box(existing_range(1,1:3),existing_range(2,1:3));
cc_ranges = proj.transform_img_to_pix(exp_range);
%
%
% identify intersection points between the image range and the symmetry plain
cross_points = box_intersect(cc_ranges ,[vec1+vec3,vec2+vec3,vec3]);
% and combine all them together
cc_exist_range = [cc_ranges,cross_points];

% transform existing range into transformed range
side_dot=cc_exist_range'*normvec;
idx = find(side_dot > 0);
cc_exist_range(:,idx) = Reflec*cc_exist_range(:,idx);
img_box_points = proj.transform_pix_to_img(cc_exist_range);
img_db_range_minmax = [min(img_box_points,[],2),max(img_box_points,[],2)]';
% add forth dimension to the range
all_sym_range = [img_db_range_minmax,existing_range(:,4)];
%
% Extract existing binning: TODO: refactor using future axes_block, extract
% common code with combine_sqw
%
new_range_arg = cell(1,4);
paxis  = false(4,1);
paxis(wout.data.pax) = true;
npax = 0;
for i=1:4
    new_range_arg{i} = all_sym_range(:,i)';
    if paxis(i)
        npax = npax+1;
        np = numel(wout.data.p{npax});
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

% Turn off horace_info output, but save for automatic clean-up on exit or cntrl-C (TGP 30/11/13)
info_level = get(hor_config,'log_level');
cleanup_obj=onCleanup(@()set(hor_config,'log_level',info_level));
set(hor_config,'log_level',-1);

% completely break relationship between bins and pixels in memory and make
% all pixels contribute into single large bin
wout.data.img_range = all_sym_range ;

wout.data.nbins_all_dims = ones(1,4);
wout.data.npix = sum(wout.data.npix(:));
%
wout=cut(wout,proj,new_range_arg{:});
