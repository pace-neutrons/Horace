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


proj    = win.data.proj;
[qw,en] = proj.transform_pix_to_hkl(win.pix);

% package as cell array of column vectors for convenience with fitting routines etc.
qw = {qw(1,:)', qw(2,:)', qw(3,:)',en(:)};

