function img_coord = calculate_uproj_pixels(win,opt)
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
%           Default: units of projection axes un-normalised by step size
%
% Output:
% -------
% img_coord  4xnpix array of components of pixels in the dataset along 
%            the projection axes

% Original author: T.G.Perring


if numel(win)~=1
    error('HORACE:calculate_uproj_pixels:invalid_argument',...
        'Only a single sqw object is valid - cannot take an array of sqw objects')
end

step=false;
if exist('opt','var')
    if ischar(opt) && strncmpi(opt,'step',numel(opt))
        step = true;
    else
        error('HORACE:calculate_uproj_pixels:invalid_argument',...
            'Invalid optional argument - the only permitted option is ''step''')
    end
end

img_coord = win.data.proj.transform_pix_to_img(win.pix.coordinates);

if step
    % Get bin centres and step sizes    
    img_range = win.data.axes.img_range;
    step = (img_range(2,:)-img_range(1,:))./win.data.axes.nbins_all_dims;
    img_coord = (img_coord-img_range(1,:)')./step';
end
