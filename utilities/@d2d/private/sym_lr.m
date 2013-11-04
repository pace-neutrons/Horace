function wout=sym_lr(win)
%
% Symmetrise a 2d horace object (d2d or 2d-sqw) about the midpoint (which
% must be x=0).
%

wout=win;
for i=1:numel(win)

    wtemp=win(i);

    if isa(win,'d2d')
        wtemp.s=flipud(win(i).s);
        wtemp.e=flipud(win(i).e);
        wtemp.npix=flipud(win(i).npix);

        wout(i).s=0.5.*(win(i).s + wtemp.s);
        wout(i).e = wout(i).s ./ (sqrt( (win(i).s ./ win(i).e).^2 + (wtemp.s ./ wtemp.e).^2));
        wout(i).npix = wtemp.npix .* win(i).npix;%gets the zeros in the right place.
        %npix otherwise has no meaning

    elseif isa(win,'sqw') && ndims(win.data.s)==2
        error('Cannot symmetrise sqw data. Convert to d2d, then symmetrise');
    else
        error('Input must be a d2d');
    end

end