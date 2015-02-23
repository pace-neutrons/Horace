function wout=symmetrise_sqw_multi(win,v1,v2,v3)

% wout=symmetrise_sqw_multi(win,v1,v2,v3)
%
% WORKS ONLY FOR DATA OBJECTS OF SQW-TYPE (I.E. WITH PIXEL INFO RETAINED).
%
% Symmetriese sqw dataset in the plane specified by the vectors v1, v2, and
% v3.
% v1 and v2 are two vectors which lie in the plane of the reflection plane.
% v3 is a vector connecting the plane to the origin (i.e. specifies an
% offset).
% 
% For multiple folds v1, v2 and v3 are cell arrays of vectors. The folds
% are then done one after another
%

%Modified by RAE 30/11/12 to account for possibility of non-orthogonal
%lattice (bug in previous incarnation of the code).

%Further modifications (with thanks to Marek Pikulski of ETHZ) to reduce memory load
%and decrease execution time

%Major modification allows multiple folds to be done sequentially

%==============================
%Some checks on the inputs:
win=sqw(win);
wout=win;

%New code (problem spotted by Matt Mena for case when using a single
%contributing spe file):
if ~iscell(wout.header)
    header = wout.header;
else
    header = wout.header{1};
end

if numel(wout)~=1
    error('Horace error: symmetrisation only implemented for single sqw object, not arrays of objects. Use a for-loop to deal with arrays');
end

if ~is_sqw_type(wout)
    %what we should actually do here is go to the dnd-symmetrise function
    %of the correct dimensionality
    error('Horace error: input object must be sqw type with detector pixel information');
end

%Check inputs v1, v2 and v3 are either all vectors or all cell arrays of
%vectors. (quite complicated checks, in fact!)
cellflag=0; vecflag=0;
if ~iscell(v1) && ~isvector(v1)
    error('v1 must be either a cell array or a vector');
elseif iscell(v1)
    cellflag=1;
elseif isvector(v1)
    vecflag=1;
end

if cellflag && (~iscell(v2) || ~iscell(v3))
    error('Ensure that if a cell array of vectors is given for v1, v2 or v3, then the others are cell arrays too');
end
if vecflag && (~isvector(v2) || ~isvector(v3))
    error('Ensure that if a vector is given for v1, v2 or v3, then all the others are vectors too');
end

if vecflag
    v1={v1}; v2={v2}; v3={v3};%convert to cell arrays to use the same logic below
end

%Check cell arrays are the same size
if numel(v1)~=numel(v2) || numel(v2)~=numel(v3)
    error('Ensure the cell arrays v1, v2 and v3 have the same number of elements');
end

%Check all elements of v1 are 3x1 or 1x3 vectors
for i=1:numel(v1)
    if ~isvector(v1{i})
        error('Ensure all the elements of v1 are 3-by-1 or 1-by-3 vectors');
    elseif numel(v1{i})~=3
        error('Ensure v1 comprises 3-by-1 or 1-by-3 vector(s)');
    end
    if size(v1{i})==[3,1]
        v1{i}=v1{i}';
    end
end
for i=1:numel(v2)
    if ~isvector(v2{i})
        error('Ensure all the elements of v2 are 3-by-1 or 1-by-3 vectors');
    elseif numel(v2{i})~=3
        error('Ensure v2 comprises 3-by-1 or 1-by-3 vector(s)');
    end
    if size(v2{i})==[3,1]
        v2{i}=v2{i}';
    end
end
for i=1:numel(v3)
    if ~isvector(v3{i})
        error('Ensure all the elements of v3 are 3-by-1 or 1-by-3 vectors');
    elseif numel(v3{i})~=3
        error('Ensure v3 comprises 3-by-1 or 1-by-3 vector(s)');
    end
    if size(v3{i})==[3,1]
        v3{i}=v3{i}';
    end
end

%========================

%Get B-matrix and reciprocal lattice vectors and angles
alatt=wout.header{1}.alatt;
angdeg=wout.header{1}.angdeg;

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


%================================================
%From this point on we are going to use the original symmetrise_sqw code
%executed in a loop

for nn=1:numel(v1)
    %convert the vectors specifying the reflection plane from rlu to the
    %orthonormal frame of the pix array:
    vec1=(inv(uconv))*(v1{nn}'-header.uoffset(1:3));
    vec2=(inv(uconv))*(v2{nn}'-header.uoffset(1:3));

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
    coords=@() wout.data.pix([1:3],:); % MP: emulate a pointer / lazy data copy

    num_pixels=size(wout.data.pix, 2); % MP, num_pixels=numel(coords)/3

    %Note that we allow the inclusion of an offset from the origin of the 
    %reflection plane. This is specified in rlu.
    vec3=(inv(uconv))*(v3{nn}'-header.uoffset(1:3));
    %Ensure v3 is a column vector:
    if size(vec3)==[1,3]
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
    coords_new=bsxfun(@plus, coords_new, vec3); % MP

    wout.data.pix([1:3],:)=coords_new;
    clear 'coords_new';
    coords_new = @() wout.data.pix([1:3],:); % MP: 'pointer'


    %=========================================================================

    %Now we need to calculate the new data range in terms of the coordinate
    %frame of the cut/slice/volume. To do this we must convert the coordinates
    %of the pixels to be in the coordinate frame of the slice, and then compare
    %the minima and maxima to the previous ranges.

    %Convert co-ords of pixel array to those of the slice/cut frame (remember
    %to include uoffset!!!)
    tmp=(header.u_to_rlu(1:3,1:3)) * coords_new();
    tmp=bsxfun(@plus, tmp, header.uoffset(1:3)); % MP: replaced repmat
    tmp=(inv(wout.data.u_to_rlu(1:3,1:3))) * tmp;

    coords_cut=bsxfun(@plus, tmp, wout.data.uoffset(1:3)); % MP: replaced repmat
    clear 'tmp';

    %Extra line required here to include energy in coords_cut (needed below):
    epix=@() wout.data.pix(4,:);%energy is never reflected, of course % MP: only accessed once
    coords_cut=[coords_cut;epix()]; % MP: (TODO) horzcat needs quite some memory, could reduced by resizing coords_cut first and then assigning last row

    ndims=dimensions(wout);

    for i=1:ndims
        bins=0.5.*(wout.data.p{i}(1:end-1) + wout.data.p{i}(2:end));
        min_unref{i}=min(bins)+eps;%add small amount to avoid rounding error
        max_unref{i}=max(bins)-eps;
    end

    %Extent of data after symmetrisation:
    for i=1:ndims
        binwid=wout.data.p{i}(2)-wout.data.p{i}(1);
        min_ref{i}=min(coords_cut(wout.data.pax(i),:))+binwid/2;
        max_ref{i}=max(coords_cut(wout.data.pax(i),:))-binwid/2;
    end

    clear 'coords_cut'; % MP: not needed anymore

    %==============

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
    %Notice that Horace can deal with working out the data range itself if we
    %set the plot limits to be +/-Inf

    % Turn off horace_info output, but save for automatic cleanup on exit or cntl-C (TGP 30/11/13)
    info_level = get(hor_config,'horace_info_level');
    cleanup_obj=onCleanup(@()set(hor_config,'horace_info_level',info_level));
    set(hor_config,'horace_info_level',-1);

    if ndims==1
        xstep=wout.data.p{1}(2)-wout.data.p{1}(1);
        wout=cut(wout,[min_full{1},xstep,max_full{1}]);
    %     wout=cut(wout,[-Inf,xstep,Inf]);
    elseif ndims==2
        xstep=wout.data.p{1}(2)-wout.data.p{1}(1);
        ystep=wout.data.p{2}(2)-wout.data.p{2}(1);
        wout=cut(wout,[min_full{1},xstep,max_full{1}],[min_full{2},ystep,max_full{2}]);
    %     wout=cut(wout,[-Inf,xstep,Inf],[-Inf,ystep,Inf]);
    elseif ndims==3
        xstep=wout.data.p{1}(2)-wout.data.p{1}(1);
        ystep=wout.data.p{2}(2)-wout.data.p{2}(1);
        zstep=wout.data.p{3}(2)-wout.data.p{3}(1);
        wout=cut(wout,[min_full{1},xstep,max_full{1}],[min_full{2},ystep,max_full{2}],...
            [min_full{3},zstep,max_full{3}]);
    %     wout=cut(wout,[-Inf,xstep,Inf],[-Inf,ystep,Inf],[-Inf,zstep,Inf]);
    elseif ndims==4
        xstep=wout.data.p{1}(2)-wout.data.p{1}(1);
        ystep=wout.data.p{2}(2)-wout.data.p{2}(1);
        zstep=wout.data.p{3}(2)-wout.data.p{3}(1);
        estep=wout.data.p{4}(2)-wout.data.p{4}(1);
        wout=cut(wout,[min_full{1},xstep,max_full{1}],[min_full{2},ystep,max_full{2}],...
            [min_full{3},zstep,max_full{3}],[min_full{4},estep,max_full{4}]);
    %     wout=cut(wout,[-Inf,xstep,Inf],[-Inf,ystep,Inf],[-Inf,zstep,Inf],[-Inf,estep,Inf]);
    else
        error('ERROR: Dimensions of dataset is not integer in the range 1 to 4');
    end

end
