function [ok,same_axes,mess]=check_rebinning_axes_1d(w1,w2)
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

w1_plane=w1.data.u_to_rlu(:,w1.data.pax(1));
w2_plane=w2.data.u_to_rlu(:,w2.data.pax(1));

if isequal(w1_plane,w2_plane)
    ok=true;
    same_axes=true;
    mess='';
else
    ok=false;
    same_axes=false;
    mess='Horace error: rebinning impossible for 2 1d datasets where x-axis is not the same';
end
