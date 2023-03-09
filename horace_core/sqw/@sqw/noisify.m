function wout = noisify(w,varargin)
%=========================================================================
% Adds random noise to the signal(s) of an sqw object or array of sqw
% objects, together with an additional fixed error bar. Sqw objects are
% noisified through their paged PixelData sub-objects. Alternatively
% noisifies a dnd object or array of such objects directly.
%
% Syntax:
%   >> wout = noisify (w)
%           Add noise with Gaussian distribution, with standard deviation
%           = 0.1*(maximum pixel signal value)
%
%   >> wout = noisify (w,factor)
%           Add noise with Gaussian distribution, with standard deviation
%           = factor*(maximum pixel signal value)
%
%   >> wout = noisify (w,'poisson')
%           Add noise with Poisson distribution, where the mean value at
%           a point is the value of pixel signal.
%
% Additional developer options are possible in varargin to test this
% functionality. See the PixelData noisify paging method (called below)
% and the Herbert noisify function which implements the noise addition.
%=========================================================================

wout=w;
for i=1:numel(w)
    if has_pixels(w(i))   % determine if sqw or dnd type

        % Delegate to PixelData to noisify that object on a page-by-page
        % basis using the Herbert noisify.
        wout(i) = wout(i).get_new_handle();
        wout(i).pix = w(i).pix.noisify(varargin{:});
        wout(i) = recompute_bin_data(wout(i));
    else
        % Noisify the dnd data directly with the Herbert noisify.
        [wout(i).data.s,wout(i).data.e]=noisify(w(i).data.s,w(i).data.e,varargin{:});
    end
end
