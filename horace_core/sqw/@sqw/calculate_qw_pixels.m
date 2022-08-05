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
    error('Only a single sqw object is valid - cannot take an array of sqw objects')
end

header_ave = header_average(win);

u0 = header_ave.uoffset;
u = header_ave.u_to_rlu(1:3,1:3);

% Assume that the first three axes are Q, and the 4th axis is energy
if ~all(u==eye(3))   % not identity matrix, so need to perform matrix transformation
    urlu=u*win.data.pix.q_coordinates;
    qh=urlu(1,:)';
    qk=urlu(2,:)';
    ql=urlu(3,:)';
else
    qh=win.data.pix.u1';
    qk=win.data.pix.u2';
    ql=win.data.pix.u3';
end
en=win.data.pix.dE';

if ~u0(1)==0, qh=qh+u0(1); end
if ~u0(2)==0, qk=qk+u0(2); end
if ~u0(3)==0, ql=ql+u0(3); end
if ~u0(4)==0, en=en+u0(4); end

% package as cell array of column vectors for convenience with fitting routines etc.
qw = {qh(:), qk(:), ql(:), en(:)};

