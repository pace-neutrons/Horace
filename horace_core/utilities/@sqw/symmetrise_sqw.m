function wout=symmetrise_sqw(win,v1,v2,v3)

% wout=symmetrise_sqw(win,v1,v2,v3)
%
% WORKS ONLY FOR DATA OBJECTS OF SQW-TYPE (I.E. WITH PIXEL INFO RETAINED).
%
%
% Symmetriese sqw dataset in the plane specified by the vectors v1, v2, and
% v3.
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
if ~iscell(win.header)
    header = win.header;
else
    header = win.header{1};
end

if numel(win)~=1
    error('Horace error: symmetrisation only implemented for single sqw object, not arrays of objects. Use a for-loop to deal with arrays');
end

if ~is_sqw_type(win)
    %what we should actually do here is go to the dnd-symmetrise function
    %of the correct dimensionality
    error('Horace error: input object must be sqw type with detector pixel information');
end

if numel(v1)~=3 || numel(v2)~=3 || numel(v3)~=3
    error('Symmetrise error: the vectors v1, v2 and v3 must all have 3 elements');
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
alatt=header.alatt;
angdeg=header.angdeg;

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

uconv=header.u_to_rlu(1:3,1:3);

%convert the vectors specifying the reflection plane from rlu to the
%orthonormal frame of the pix array:
%vec1=uconv\(v1'-header.uoffset(1:3));
%vec2=uconv\(v2'-header.uoffset(1:3));
vec1=uconv\(v1');
vec2=uconv\(v2');

%Normal to the plane, in the frame of pix array:
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

num_pixels=win.data.pix.num_pixels;  % MP, num_pixels=numel(coords)/3

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
coords_new([1:3], idx) = Reflec*coords_new([1:3], idx); % MP: (TODO) could potentially be optimized further
clear 'side_dot'; % MP: not needed anymore
% Testing the ranges transformation
%orig_range = win.data.pix.pix_range;
%cross_points = box_cross(orig_range,vec1,vec2,vec3);

coords_new=bsxfun(@plus, coords_new, vec3); % MP

wout.data.pix.q_coordinates=coords_new;
clear 'coords_new';
coords_new = @() wout.data.pix.q_coordinates; % MP: 'pointer'


%=========================================================================

%Now we need to calculate the new data range in terms of the coordinate
%frame of the cut/slice/volume. To do this we must convert the coordinates
%of the pixels to be in the coordinate frame of the slice, and then compare
%the minima and maxima to the previous ranges.

%Convert co-ords of pixel array to those of the slice/cut frame (remember
%to include uoffset!!!)
tmp=(header.u_to_rlu(1:3,1:3)) * coords_new();
tmp=bsxfun(@plus, tmp, header.uoffset(1:3)); % MP: replaced repmat
tmp=win.data.u_to_rlu(1:3,1:3) \ tmp;

coords_cut=bsxfun(@plus, tmp, win.data.uoffset(1:3)); % MP: replaced repmat
clear 'tmp';

%Extra line required here to include energy in coords_cut (needed below):
epix=@() win.data.pix.dE; %energy is never reflected, of course % MP: only accessed once
coords_cut=[coords_cut;epix()]; % MP: (TODO) horzcat needs quite some memory, could reduced by resizing coords_cut first and then assigning last row

ndims=dimensions(win);

%==============
%Old code before bug spotted by Matt Mena:

%Extent of data before symmetrisation:
%note we use the axes of the cut, not the pix_range, since user may have
%chosen to have white space around their slice / cut for a reason
% for i=1:ndims
%     min_unref{i}=min(win.data.p{win.data.pax(i)});
%     max_unref{i}=max(win.data.p{win.data.pax(i)});
% end
%
% %Extent of data after symmetrisation:
% for i=1:ndims
%     min_ref{i}=min(coords_cut(win.data.pax(i),:));
%     max_ref{i}=max(coords_cut(win.data.pax(i),:));
% end
%===============

%New code, after bug fix (RAE 14/3/13):
existing_range = win.data.get_bin_range();

%Extent of data after symmetrisation:
min_ref = zeros(ndims,1);
max_ref = zeros(ndims,1);
for i=1:ndims
    %binwid=win.data.p{i}(2)-win.data.p{i}(1);
    min_ref(i)=min(coords_cut(win.data.pax(i),:))+existing_range{i}(2)/2;
    max_ref(i)=max(coords_cut(win.data.pax(i),:))-existing_range{i}(2)/2;
end

clear 'coords_cut'; % MP: not needed anymore

%==============

%Now work out the full extent of the symmetrised data:
min_full = zeros(ndims,1);
max_full = zeros(ndims,1);
for i=1:ndims
    min_full(i)=min(existing_range{i}(1), min_ref(i));
    max_full(i)=max(existing_range{i}(3), max_ref(i));
end

%We have to ensure that we also adjust the pix_range field appropriately:
new_range = cell(ndims,1);
for i=1:ndims
    %step=wout.data.p{i}(2)-wout.data.p{i}(1);
    %add a little bit either side, to be sure of getting everything
    wout.data.img_range(1,wout.data.pax(i))=min_full(i)-existing_range{i}(2);
    wout.data.img_range(2,wout.data.pax(i))=max_full(i)+existing_range{i}(2);
    new_range{i} = [min_full(i),existing_range{i}(2),max_full(i)];
end

%cannot use recompute_bin_data to get the new object...
%Notice that Horace can deal with working out the data range itself if we
%set the plot limits to be +/-Inf

% Turn off horace_info output, but save for automatic clean-up on exit or cntl-C (TGP 30/11/13)
info_level = get(hor_config,'log_level');
cleanup_obj=onCleanup(@()set(hor_config,'log_level',info_level));
set(hor_config,'log_level',-1);

wout=cut(wout,new_range{:});

% if ndims==1
%     xstep=win.data.p{1}(2)-win.data.p{1}(1);
%     wout=cut(wout,[min_full(1),xstep,max_full(1)]);
% %     wout=cut(wout,[-Inf,xstep,Inf]);
% elseif ndims==2
%     xstep=win.data.p{1}(2)-win.data.p{1}(1);
%     ystep=win.data.p{2}(2)-win.data.p{2}(1);
%     wout=cut(wout,[min_full(1),xstep,max_full(1)],[min_full(2),ystep,max_full(2)]);
% %     wout=cut(wout,[-Inf,xstep,Inf],[-Inf,ystep,Inf]);
% elseif ndims==3
%     xstep=win.data.p{1}(2)-win.data.p{1}(1);
%     ystep=win.data.p{2}(2)-win.data.p{2}(1);
%     zstep=win.data.p{3}(2)-win.data.p{3}(1);
%     wout=cut(wout,[min_full(1),xstep,max_full(1)],[min_full(2),ystep,max_full(2)],...
%         [min_full(3),zstep,max_full(3)]);
% %     wout=cut(wout,[-Inf,xstep,Inf],[-Inf,ystep,Inf],[-Inf,zstep,Inf]);
% elseif ndims==4
%     xstep=win.data.p{1}(2)-win.data.p{1}(1);
%     ystep=win.data.p{2}(2)-win.data.p{2}(1);
%     zstep=win.data.p{3}(2)-win.data.p{3}(1);
%     estep=win.data.p{4}(2)-win.data.p{4}(1);
%     wout=cut(wout,[min_full(1),xstep,max_full(1)],[min_full(2),ystep,max_full(2)],...
%         [min_full(3),zstep,max_full(3)],[min_full(4),estep,max_full(4)]);
% %     wout=cut(wout,[-Inf,xstep,Inf],[-Inf,ystep,Inf],[-Inf,zstep,Inf],[-Inf,estep,Inf]);
% else
%     error('ERROR: Dimensions of dataset is not integer in the range 1 to 4');
% end
