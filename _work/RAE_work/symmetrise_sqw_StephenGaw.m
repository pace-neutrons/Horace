function wout=symmetrise_sqw_corrected_2(win,v1,v2,v3)

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

% Modified by SMG 22/07/12 to account for SQW objects generated from single
% SPE file, and mis-indexing in line to 198, 199, 206 and 207 when symming
% 3D object

%==============================
%Some checks on the inputs:
win=sqw(win);
wout = copy(win);

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

if size(v1)==[3,1]
    v1=v1';
end
if size(v2)==[3,1]
    v2=v2';
end
if size(v3)==[3,1]
    v3=v3';
end


%========================

%Get B-matrix and reciprocal lattice vectors and angles

% alatt=win.header{1}.alatt;    % original code from RAE
% angdeg=win.header{1}.angdeg;

if iscell(win.header),  % edited code (SMG, 22/07/2013) to work with SQW made from single SPE file
    alatt=win.header{1}.alatt;
    angdeg=win.header{1}.angdeg;
elseif ~iscell(win.header) && isstruct(win.header),
    alatt=win.header.alatt;
    angdeg=win.header.angdeg;
end

[b, arlu, angrlu] = bmatrix(alatt, angdeg);


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

uconv=win.header{1}.u_to_rlu(1:3,1:3);  % original RAE code

if iscell(win.header),  % edited code (SMG, 22/07/2013) to work with SQW made from single SPE file
    uconv=win.header{1}.u_to_rlu(1:3,1:3);
    uoffset=win.header{1}.uoffset(1:3);
elseif ~iscell(win.header) && isstruct(win.header),
    uconv=win.header.u_to_rlu(1:3,1:3);
    uoffset=win.header.uoffset(1:3);
end


%convert the vectors specifying the reflection plane from rlu to the
%orthonormal frame of the pix array:
% vec1=(inv(uconv))*(v1'-win.header{1}.uoffset(1:3));   % original RAE code
% vec2=(inv(uconv))*(v2'-win.header{1}.uoffset(1:3));
vec1=(inv(uconv))*(v1'-uoffset);   % edit: SMG (22/07/2013) to work with SQW from single SPE
vec2=(inv(uconv))*(v2'-uoffset);

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
coords=win.data.pix.q_coordinates;

%Note that we allow the inclusion of an offset from the origin of the
%reflection plane. This is specified in rlu.
% vec3=(inv(uconv))*(v3'-win.header{1}.uoffset(1:3));
vec3=(inv(uconv))*(v3'-uoffset);
%Ensure v3 is a column vector:
if size(vec3)==[1,3]
    vec3=vec3';
end

%Repeat v3 so that it has 3 rows, and the no. of columns = no. det. pixels
v3new=repmat(vec3,1,(numel(coords))/3);

%Translate the pixel co-ords by v3:
coords_transl=coords-v3new;

%Reflect the translated co-ords:
coords_refl=Reflec*coords_transl;

%What we want to do now is to replace elements of the pix array whose
%coordinates are on one side of the plane with coords_refl, but not replace the elements on
%the other side of the reflection plane.

%Can determine which side of the plane a given point is on by taking the
%dot product of the normal and the coordinate of the point relative to some
%position in the plane.

normmat=repmat(normvec,1,numel(coords) / 3);

side_dot=dot(normmat,coords_transl);

keepit=repmat(side_dot<=0,3,1);%keep points on RHS
reflit=repmat(side_dot>0,3,1);%use reflected point (is on LHS)

coords_new=coords_transl.*keepit + coords_refl.*reflit;

coords_new=coords_new+v3new;

wout.data.pix.q_coordinates=coords_new;

%=========================================================================

%Now we need to calculate the new data range in terms of the coordinate
%frame of the cut/slice/volume. To do this we must convert the coordinates
%of the pixels to be in the coordinate frame of the slice, and then compare
%the minima and maxima to the previous ranges.

%Convert co-ords of pixel array to those of the slice/cut frame (remember
%to include uoffset!!!)
% tmp=(win.header{1}.u_to_rlu(1:3,1:3)) * coords_new; % original RAE code
tmp=(uconv) * coords_new;   % edit: SMG (22/07/2013) to work with SQW from single SPE
% uoff_arr=repmat(win.header{1}.uoffset(1:3),1,numel(coords)/3);    % original RAE code
uoff_arr=repmat(uoffset,1,numel(coords)/3);  % edit: SMG (22/07/2013) to work with SQW from single SPE
tmp=tmp+uoff_arr;

tmp=(inv(win.data.u_to_rlu(1:3,1:3))) * tmp;

uoff_arr=repmat(win.data.uoffset(1:3),1,numel(coords)/3);
coords_cut=tmp+uoff_arr;

ndims=dimensions(win);

%Extent of data before symmetrisation:
%note we use the axes of the cut, not the urange, since user may have
%chosen to have white space around their slice / cut for a reason
for i=1:ndims
%     min_unref{i}=min(win.data.p{win.data.pax(i)});    % original RAE code (tries to find win.data.p{4}, which doesn't exist!)
%     max_unref{i}=max(win.data.p{win.data.pax(i)});
    min_unref{i}=min(win.data.p{i});    % editted: SMG 22/07/2013: to just index at the 3 dimensions
    max_unref{i}=max(win.data.p{i});
end

%Extent of data after symmetrisation:
for i=1:ndims
%     min_ref{i}=min(coords_cut(win.data.pax(i),:));    % original RAE code (tries to find win.data.p{4}, which doesn't exist!)
%     max_ref{i}=max(coords_cut(win.data.pax(i),:));
    min_ref{i}=min(coords_cut(i,:));  % editted: SMG 22/07/2013: to just index at the 3 dimensions
    max_ref{i}=max(coords_cut(i,:));
end

%Now work out the full extent of the symmetrised data:
for i=1:ndims
    min_full{i}=min([min_unref{i} min_ref{i}]);
    max_full{i}=max([max_unref{i} max_ref{i}]);
end

%We have to ensure that we also adjust the urange field appropriately:
for i=1:ndims
    step=wout.data.p{i}(2)-wout.data.p{i}(1);
    %add a little bit either side, to be sure of getting everything
    wout.data.urange(1,wout.data.pax(i))=min_full{i}-step;
    wout.data.urange(2,wout.data.pax(i))=max_full{i}+step;
end

%cannot use recompute_bin_data to get the new object...
horace_info_level(-Inf);
if ndims==1
    xstep=win.data.p{1}(2)-win.data.p{1}(1);
    wout=cut(wout,[min_full{1},xstep,max_full{1}]);
elseif ndims==2
    xstep=win.data.p{1}(2)-win.data.p{1}(1);
    ystep=win.data.p{2}(2)-win.data.p{2}(1);
    wout=cut(wout,[min_full{1},xstep,max_full{1}],[min_full{2},ystep,max_full{2}]);
elseif ndims==3
    xstep=win.data.p{1}(2)-win.data.p{1}(1);
    ystep=win.data.p{2}(2)-win.data.p{2}(1);
    zstep=win.data.p{3}(2)-win.data.p{3}(1);
    wout=cut(wout,[min_full{1},xstep,max_full{1}],[min_full{2},ystep,max_full{2}],...
        [min_full{3},zstep,max_full{3}]);
elseif ndims==4
    xstep=win.data.p{1}(2)-win.data.p{1}(1);
    ystep=win.data.p{2}(2)-win.data.p{2}(1);
    zstep=win.data.p{3}(2)-win.data.p{3}(1);
    estep=win.data.p{4}(2)-win.data.p{4}(1);
    wout=cut(wout,[min_full{1},xstep,max_full{1}],[min_full{2},ystep,max_full{2}],...
        [min_full{3},zstep,max_full{3}],[min_full{4},estep,max_full{4}]);
else
    error('ERROR: Dimensions of dataset is not integer in the range 1 to 4');
end
horace_info_level(Inf);
