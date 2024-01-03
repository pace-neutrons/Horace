function wout = slim (win, reduce)
% Slim an sqw object by removing random pixels
%
%   >> wout = slim (win, factor)
%
% Input:
% ------
%   win     Input sqw object or array of sqw objects
%   reduce  Factor by which to reduce the number of pixels (reduce >=1)
%          e.g. reduce=5 will reduce the number of pixels by a factor 5.
%
% Output:
% -------
%   wout    Output sqw object or array of szqw objects

if reduce<1
    error('HORACE:sqw:invalid_argument', ...
        'reduce factor has to be greater than or equal to 1. It is %s', ...
        disp2str(reduce));
end

wout = mask_random_fraction_pixels(win, 1/reduce);

end
