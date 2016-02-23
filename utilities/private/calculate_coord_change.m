function wout=calculate_coord_change(v1,v2,w1)
%
% We take a set of coordinates centred at v1 (row vec), and work out how to map them
% onto a Brillouin zone centred at v2. The objects w1 and w2 are
% 4-dimensional sqw objects that are respectively centred at v1 and v2.
%
% We define what we're doing as shifting the coordinates of w1 so that they
% map on to those of w2.

%Crude test to ensure that v1 and v2 are equivalent wavevectors:
if sum(v1.^2)~=sum(v2.^2)
    error('Horace error: Brillouin zone centres are not equivalent');
end

%Initialise the output:
wout=w1;
if v1==v2
    return;
end

%Create a vector that has h and k swapped relative to v2
v2swap=[v2(1); v2(1); v2(3)];

%Also ensure that v1 and v2 are column vectors:
if ~isequal(size(v1),[3,1])
    v1=v1';
end
if ~isequal(size(v2),[3,1])
    v2=v2';
end

%Now work out which way the permutation has been done:
av1=abs(v1); av2=abs(v2); av2swap=abs(v2swap);
if av2==av1
    shift=0;
elseif av2==circshift(av1,[1,0]);
    shift=1;
elseif av2==circshift(av1,[2,0]);
    shift=2;
elseif av1==av2swap
    shift=3;
elseif av2swap==circshift(av1,[1,0]);
    shift=4;
elseif av2swap==circshift(av1,[2,0]);
    shift=5;
end

%Next we must determine whether we need to flip an axis round:
switch shift
    case 0
        ax=v2./v1;
        indx=[1; 2; 3];
    case 1
        ax=v2./circshift(v1,1);
        indx=[3; 1; 2];
    case 2
        ax=v2./circshift(v1,2);
        indx=[2; 3; 1];
    case 3
        ax=v2swap./v1;
        indx=[2; 1; 3];
    case 4
        ax=v2swap./circshift(v1,1);
        indx=[3; 2; 1];
    case 5
        ax=v2swap./circshift(v1,2);
        indx=[1; 3; 2];
end

%NB, if we have zeros in v1 or v2 we can get NaN or Inf elements for ax. If
%it is NaN then we have 0./0. If an element is Inf then something has gone
%wrong!
ax(isnan(ax))=1;
if any(abs(ax)>1.001)
    error('Horace error: Brillouin zone centres are not equivalent'); 
end

%Now we work out how to alter each of the objects:
%
coords1=w1.data.pix(1:3,:);
%coords2=w2.data.pix([1:3],:);
p1=w1.data.p;
%p2=w2.data.p;

%We must ensure that we look at the coordinates in terms of reciprocal
%lattice units:
u_to_rlu1=w1.data.u_to_rlu(1:3,1:3);
umat1=repmat(w1.data.ulen(1:3)',1,3);
T1=u_to_rlu1./umat1;
coords_rlu1=T1*coords1;
%
%This bit is for debug:
%u_to_rlu2=w2.data.u_to_rlu(1:3,1:3);
%umat2=repmat(w2.data.ulen(1:3)',1,3);
%T2=u_to_rlu2./umat2;
%coords_rlu2=T2*coords2;

fullax=repmat(ax,1,(numel(coords1))/3);

if shift>2.5
    % we swap round h and k first
    coords_rlu1=[coords_rlu1(2,:); coords_rlu1(1,:); coords_rlu1(3,:)];
    coords_rlu1=circshift(coords_rlu1,[shift-3,0]);
else
    coords_rlu1=circshift(coords_rlu1,[shift,0]);
end
coords_rlu1=coords_rlu1.*fullax;

%Convert coordinates back to inverse Angstroms:
coords_ang1=(inv(T1))*coords_rlu1;

%Make the required changes to the p1 cell array:
p1new=p1;
for i=1:3
    p1new{i}=p1{indx(i)};
    if ax(i)==-1
        p1new{i}=flipud(-1.*p1new{i});
    end
end

%Place the new coords_ang1 and p1 arrays into the output object:
wout.data.pix(1:3,:)=coords_ang1;
wout.data.p=p1new;

%Use the internal Horace routines to recalculate intensity/error/npix etc
%arrays:
argi = cell(1,numel(p1new));
wout=cut(wout,argi{:});



