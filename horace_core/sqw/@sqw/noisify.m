function wout = noisify(w,varargin)
% Adds random noise to an sqw object or array of sqw objects
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
% Modified to use the object paging functionality. The "noisify" overload
% required here is the one in PixelData which in turn will call the Herbert 
% noisify which has been modified to use paging. For dnd type data the same
% Herbert noisify is called directly.
wout=w;
for i=1:numel(w)
    if is_sqw_type(w(i))   % determine if sqw or dnd type
        wout(i).data.pix = w(i).data.pix.noisify(varargin{:});
        wout(i)=recompute_bin_data(wout(i));
    else
        [wout(i).data.s,wout(i).data.e]=noisify(w(i).data.s,w(i).data.e,varargin{:});
    end
end

