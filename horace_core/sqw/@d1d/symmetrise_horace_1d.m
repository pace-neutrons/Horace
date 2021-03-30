function wout=symmetrise_horace_1d(win, midpoint)
%
% wout=symmetrise_horace_1d(win,midpoint)
%
% Symmetrise a d1d dataset (or an sqw dataset of dnd-type) about a
% specified midpoint.
%
% e.g. wout=symmetrise_horace_1d(win,0)
% symmetrises data about x=0.
%
% Output:
%   d1d object containing symmetrised data
%
% RAE 21/1/10
%

%Known issue when midpoint is not a bin boundary. We throw away the pixels
%that are to the left of the mid point. If this is not a bin boundary then
%we throw away the pixels that are in the bin in which the midpoint lies.

[ndims, ~]=dimensions(win);

if ndims~=1
    error('Horace error: ensure input object is 1-dimensional')
end

if isa(win,'sqw') && has_pixels(win)
    error('Horace error: d1d method cannot be used for sqw objects with pixel info. Logic flaw');
end

xin=win.data_.p{1};
sin=win.data_.s;
ein=win.data_.e;
nin=win.data_.npix;

[xout,sout,eout,nout]=symmetrise_1d(xin,sin,ein,nin,midpoint);

wout=d1d(getout);
wout.data_.p{1}=xout(:,1);
wout.data_.s=sout;
wout.data_.e=eout;
wout.data_.npix=nout;
wout.data_.title=[wout.data_.title,' SYMMETRISED '];
