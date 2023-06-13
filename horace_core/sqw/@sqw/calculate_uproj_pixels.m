function img_coord = calculate_uproj_pixels(win,step)
% Calculate coordinates in projection axes for the pixels in an sqw dataset
%
%   >> qw=calculate_uproj_pixels(win)
%   >> qw=calculate_uproj_pixels(win,'step')
%
% Input:
% ------
%   win     Input sqw object
%   step    Option for units of the output
%           If present, define projections in units of the step size
%           provided.
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

do_step=false;
if exist('step','var')
    if isnumeric(step) && numel(step) == 4
        do_step = true;
        step = reshape(step,4,1);
    else
        error('HORACE:calculate_uproj_pixels:invalid_argument',...
            'Invalid optional argument - the only permitted option is 4-element vector of steps')
    end
end

img_coord = win.data.proj.transform_pix_to_img(win.pix);

if do_step
    % Get bin centres and step sizes
    %img_range = win.data.axes.img_range;
    %img_coord = (img_coord-img_range(1,:)')./step;
    img_coord = img_coord./step;
end
