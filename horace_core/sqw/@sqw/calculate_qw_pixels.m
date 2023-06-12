function qw=calculate_qw_pixels(win)
% Calculate qh,qk,ql,en for the pixels in an sqw dataset
%
%   >> qw=calculate_qw_pixels(win)
%
% Input:
% ------
%   win     Input sqw object
%
% Output:
% -------
%   qw      Components of momentum (in rlu) and energy for each pixel in the dataset
%           Arrays are packaged as cell array of column vectors for convenience
%           with fitting routines etc.
%               i.e. qw{1}=qh, qw{2}=qk, qw{3}=ql, qw{4}=en

% Get some 'average' quantities for use in calculating transformations and bin boundaries
% *** assumes that all the contributing spe files had the same lattice parameters and projection axes
% This could be generalised later - but with repercussions in many routines

if numel(win)~=1
    error('HORACE:sqw:invalid_argument', ...
        'Only a single sqw object is valid - cannot take an array of sqw objects')
end


proj       = win.data.proj;
offset     = win.data.proj.offset;
% Re #1034 is this necessary?
%hkl_offset = offset(1:3);
% we need the projection into real hkl, aligned with Crystal Cartesian, not
% rotated wrt it.
if isempty(proj.ub_inv_legacy)
    b_mat = bmatrix(proj.alatt,proj.angdeg);
    % Pixels are never offset? % Re #1034 is this necessary?
    %qw = b_mat\win.pix.q_coordinates+hkl_offset(:) ;
    qw = b_mat\win.pix.q_coordinates;
else
    % support legacy crystal alignment. TODO: Should go in a future
    % Pixels are never offset? % Re #1034 is this necessary?    
    %qw = proj.ub_inv_legacy*win.pix.q_coordinates-hkl_offset(:);
    qw = proj.ub_inv_legacy*win.pix.q_coordinates;
end
if abs(offset(4))>4*eps('single')
    % Re #1034 is this necessary?    
    % en = win.pix.dE+offset(4);
else
    en = win.pix.dE;    
end

% package as cell array of column vectors for convenience with fitting routines etc.
qw = {qw(1,:)', qw(2,:)', qw(3,:)', en(:)};

