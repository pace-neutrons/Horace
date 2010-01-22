function [ok,same_axes,mess]=check_rebinning_axes(w1,w2)
% subroutine to determine if the projection axes of w1 and w2 are the same.
% note that if the axes are in a different plane then we throw an error
% message.

ok=false; same_axes=false; mess='';

w1=sqw(w1); w2=sqw(w2);

%We decide to throw an error message if the sample is different (i.e. we
%try to rebin the data on to a grid associated with different lattice
%parameters).
if ~isequal(w1.data.alatt,w2.data.alatt) || ~isequal(w1.data.angdeg,w2.data.angdeg)
    ok=false;
    mess='Horace error: rebinning impossible for 2 datasets where lattice parameters are different';
    return;
end

w1_plane=[w1.data.u_to_rlu(:,w1.data.pax(1)) w1.data.u_to_rlu(:,w1.data.pax(2))];
w2_plane=[w2.data.u_to_rlu(:,w2.data.pax(1)) w2.data.u_to_rlu(:,w2.data.pax(2))];

evec=[0;0;0;1];
if isequal(w1_plane(4,:),[0,0]) && isequal(w2_plane(4,:),[0,0])
    %neither object is a slice with an energy axis
    w1_plane=w1_plane([1:3],:); w2_plane=w2_plane([1:3],:);
    perp1=cross(w1_plane(:,1),w1_plane(:,2));
    perp2=cross(w2_plane(:,1),w2_plane(:,2));
    %
    %Must ensure these vectors are normalised:
    perp1=perp1./(sqrt(sum(perp1.^2)));
    perp2=perp2./(sqrt(sum(perp2.^2)));
    %
    if isequal(perp1,perp2) || isequal(perp1,(-1.*perp2))
        %parallel, or antiparallel
        ok=true;
    else
        ok=false;
        mess='Horace error: rebinning impossible when 2 objects have different scattering planes';
        return;
    end
    %
    %Before we do anything else, get rid of rounding errors:
    w1_plane(w1_plane<1e-5)=0;
    w2_plane(w2_plane<1e-5)=0;
    %
    %Now must determine if the scattering plane is the same for both
    %objects:
    if (isequal(cross(w1_plane(:,1),w2_plane(:,1)),[0;0;0]) || isequal(cross(w1_plane(:,1),w2_plane(:,2)),[0;0;0])) &&...
            (isequal(cross(w1_plane(:,2),w2_plane(:,1)),[0;0;0]) || isequal(cross(w1_plane(:,2),w2_plane(:,2)),[0;0;0]))
        same_axes=true;%NB we must deal with the case where the axes are the same, but
        %x and y are swapped between the objects. e.g. [1,0,0]/[0,1,0]
        %plane vs [0,1,0]/[1,0,0] plane.
    else
        same_axes=false;
    end
elseif (sum(w1_plane(4,:))==sum(w2_plane(4,:))) && sum(w1_plane(4,:))==1
    %both objects have 1 axis as energy axis
    w1_plane=w1_plane([1:3],:); w2_plane=w2_plane([1:3],:);
    p11=cross(w1_plane(:,1),w2_plane(:,1));
    p12=cross(w1_plane(:,1),w2_plane(:,2));
    p21=cross(w1_plane(:,2),w2_plane(:,1));
    p22=cross(w1_plane(:,2),w2_plane(:,2));
    zvec=[0;0;0];
    if isequal(p11,zvec) && isequal(p12,zvec) && isequal(p21,zvec) && isequal(p22,zvec)
        same_axes=true; ok=true;
    else
        same_axes=false; ok=false;%i.e. for a Q/E slice Q must be the same for both objects in Horace,
        %since we cannot have axes that are a mixture of Q and E.
    end
end

    
