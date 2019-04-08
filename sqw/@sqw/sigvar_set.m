function w = sigvar_set(w,sigvarobj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(w,sigvarobj)

% Original author: T.G.Perring
%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)

if ~isequal(size(w.data.s),size(sigvarobj.s))
    error('sqw object and sigvar object have inconsistent sizes')
end

w.data.s=sigvarobj.s;
w.data.e=sigvarobj.e;

if is_sqw_type(w)
    % RAE spotted error 8/12/2010: should only create pix field if sqw object
    stmp = replicate_array(w.data.s, w.data.npix)';
    etmp = replicate_array(w.data.e, w.data.npix)';
    w.data.pix(8:9,:) = [stmp;etmp]; % propagate signal into the pixel data
end

% If no pixels, then our convention is that signal and error set to zero
nopix=(w.data.npix==0);
w.data.s(nopix)=0;
w.data.e(nopix)=0;
