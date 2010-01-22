function wout=symmetrise_sqw(win,v1,v2,v3)
%
% wout=symmetrise_sqw(win,v1,v2,v3)
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
% RAE 21/1/10
%


win=sqw(win);
wout=win;

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

%===========

conversion=2*pi./win.data.alatt;%note this is equivalent to win.data.ulen for
%the special case of axes (h,0,0)/(0,k,0)/(0,0,l)

% vec1=diag(win.data.ulen(1:3),0) * v1';
% vec2=diag(win.data.ulen(1:3),0) * v2';

vec1=diag(conversion,0) * v1';
vec2=diag(conversion,0) * v2';

%vec1=v1'; vec2=v2';


if size(vec1)==[3,1]
    vec1=vec1';
end
if size(vec2)==[3,1]
    vec2=vec2';
end

% vec1p=(win.data.u_to_rlu([1:3],[1:3]))'*vec1';
% vec2p=(win.data.u_to_rlu([1:3],[1:3]))'*vec2';

vec1p=inv(win.data.u_to_rlu([1:3],[1:3]))*vec1';
vec2p=inv(win.data.u_to_rlu([1:3],[1:3]))*vec2';

normvec=cross(vec1,vec2);
%we must define the plane using 2 (non parallel) vectors that lie in it.
%This then gives us both the normal to the plane, and also where along the
%normal direction the plane sits

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

normvec2=cross(vec1p,vec2p);
Reflec2=zeros(3,3);%initialise reflection matrix
for i=1:3
    for j=1:3
        if i==j
            delt=1;
        else
            delt=0;
        end
        Reflec2(i,j)=delt - (2 * normvec2(i) .* normvec2(j))./(sum(normvec2.^2));
    end
end

coords=win.data.pix([1:3],:);

%First must translate the coordinates, in case the reflection plane does
%not go through the origin. We have specified a random point on the plane
%using the vector v3.

%Must ensure we convert v3 to rlu, since otherwise it will be in inverse
%angstroms.

%vec3=diag(win.data.ulen(1:3),0) * v3';

vec3=diag(conversion,0) * v3';

% vec3=v3';

%Ensure v3 is a column vector:
if size(vec3)==[1,3]
    vec3=vec3';
end
v3new=repmat(vec3,1,(numel(coords))/3);

coords_transl=coords-v3new;


coords_refl=Reflec*coords_transl;

%What we want to do now is to replace elements of the pix array whose
%hkl coordinates are on one side of the plane with coords_refl, but not replace the elements on
%the other side of the reflection plane.

%Can determine which side of the plane a given point is on by taking the
%dot product of the normal and the coordinate of the point relative to some
%position in the plane.

normmat=repmat(normvec',1,numel(coords) / 3);

side_dot=dot(normmat,coords_transl);

keepit=repmat(side_dot<=0,3,1);%keep points on RHS
reflit=repmat(side_dot>0,3,1);%use reflected point (is on LHS)

coords_new=coords_transl.*keepit + coords_refl.*reflit;

coords_new=coords_new+v3new;

wout.data.pix([1:3],:)=coords_new;

ndims=dimensions(win);

%Note that we must now check if the data range has changed (e.g. we
%symmetrised along some diagonal such that the lower limit of x is now
%smaller). Calculate the limits from the coords_new array.
%It is made a bit simpler by the fact that the co-ordinate system before
%and after is the same.

%First work out minima and maxima of original co-ordinates:
coords_rlu=inv(win.data.u_to_rlu) * win.data.pix([1:4],:);
rlutrans=[(2*pi./win.data.alatt)'; 1];
coords_rlu=coords_rlu./repmat(rlutrans,1,numel(coords_rlu) /4);
%
for i=1:ndims
    min_unref{i}=min(coords_rlu(win.data.pax(i),:));
    max_unref{i}=max(coords_rlu(win.data.pax(i),:));
end

%Next do the same for the reflected co-ordinates:
coords_new=[coords_new; win.data.pix(4,:)];%energy axis should never be altered
coords_rlu_new=inv(win.data.u_to_rlu) * coords_new([1:4],:);
%rlutrans=[(2*pi./win.data.alatt)'; 1];
coords_rlu_new=coords_rlu_new./repmat(rlutrans,1,numel(coords_rlu_new) /4);
%
for i=1:ndims
    min_ref{i}=min(coords_rlu_new(win.data.pax(i),:));
    max_ref{i}=max(coords_rlu_new(win.data.pax(i),:));
end

%Now work out the full extent of the symmetrised data:
for i=1:ndims
    min_full{i}=min([min_unref{i} min_ref{i}]);
    max_full{i}=max([max_unref{i} max_ref{i}]);
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

