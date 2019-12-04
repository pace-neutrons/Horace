function wout=symmetrise_horace_1d(win,midpoint)
%
% wout=symmetrise_horace_1d(win,midpoint)
%
% Symmetrise a d1d dataset (or an sqw dataset of dnd-type) about a 
% specified midpoint.
%
% e.g. wout=symmetrise_horace_1d(win,0)
% symmetrises data about x=0.
%
% RAE 21/1/10
%

%Known issue when midpoint is not a bin boundary. We throw away the pixels
%that are to the left of the mid point. If this is not a bin boundary then
%we throw away the pixels that are in the bin in which the midpoint lies.

[ndims,sz]=dimensions(win);

if ndims~=1 
    error('Horace error: ensure input object is 1-dimensional')   
end

if isa(win,'sqw')
    if is_sqw_type(sqw(win))
        error('Horace error: d1d method cannot be used for sqw objects with pixel info. Logic flaw');
    end
end

win=sqw(win);

xin=win.data.p{1};
sin=win.data.s; ein=win.data.e; nin=win.data.npix;

[xout,sout,eout,nout]=symmetrise_1d(xin,sin,ein,nin,midpoint);

wout=d1d(win);
getout=get(wout);
getout.p{1}=xout(:,1);
getout.s=sout; getout.e=eout; getout.npix=nout;
getout.title=[wout.title,' SYMMETRISED '];
wout=d1d(getout);