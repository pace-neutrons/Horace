function uproj=calculate_uproj_pixels(win,opt)
% Calculate coordinates in projection axes for the pixels in an sqw dataset
%
%   >> qw=calculate_uproj_pixels(win)
%   >> qw=calculate_uproj_pixels(win,'step')
%
% Input:
% ------
%   win     Input sqw object
%   opt     Option for units of the output
%           'step'      in units of the step size/integration range for each axis
%           Default: units of projection axes unnormalised by step size
%
% Output:
% -------
%   u       Components of pixels in the dataset along the projection axes
%           Arrays are packaged as cell array of column vectors for convenience
%           with fitting routines etc.
%               i.e. qw{1}=qh, qw{2}=qk, qw{3}=ql, qw{4}=en


% Original author: T.G.Perring
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)


if numel(win)~=1
    error('Only a single sqw object is valid - cannot take an array of sqw objects')
end

step=false;
if exist('opt','var')
    if ischar(opt) && strncmpi(opt,'step',numel(opt))
        step = true;
    else
        error('Invalid option')
    end
end

header_ave=header_average(win.header);

upix_offset = header_ave.uoffset;
upix_to_rlu = header_ave.u_to_rlu(1:3,1:3);

uproj_to_rlu = win.data.u_to_rlu(1:3,1:3);
uproj_offset = win.data.uoffset;

iax = win.data.iax;
iint = win.data.iint;
pax = win.data.pax;
p = win.data.p;

% Get bin centres and step sizes
ustep = zeros(1,4);
for i=1:numel(pax)
    ustep(pax(i)) = (p{i}(end)-p{i}(1))/(numel(p{i})-1);
end
for i=1:numel(iax)
    ustep(iax(i)) = abs(iint(2,i)-iint(1,i));    % taks abs to ensure always >=0
end

% Get pixels in appropriate units along projection axes
if step
    uproj_to_rlu = repmat(ustep(1:3),3,1).*uproj_to_rlu;
end
u = (uproj_to_rlu\upix_to_rlu)*win.data.pix(1:3,:) -...
    uproj_to_rlu\(uproj_offset(1:3)-upix_offset(1:3));
en = (win.data.pix(4,:) - (uproj_offset(4)-upix_offset(4)))/ustep(4);

% package as cell array of column vectors
uproj = {u(1,:)', u(2,:)', u(3,:)', en'};
