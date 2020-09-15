function wout = noisify (w,varargin)
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
% required here is the one in Herbert taking separate signal and error
% arguments before varargin. I *think* this overload is resolved at call
% time and consequently further specification at this point is not needed.
wout=w;
for i=1:numel(w)
    if is_sqw_type(w(i))   % determine if sqw or dnd type
        wout(i).data.pix = w(i).data.pix.do_sigvar_pair_va_op(@noisify, varargin{:});
        wout(i)=recompute_bin_data(wout(i));
    else
        [wout(i).data.s,wout(i).data.e]=noisify(w(i).data.s,w(i).data.e,varargin{:});
    end
end

