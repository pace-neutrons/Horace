function wout = disp2sqw(win, dispreln, pars, fwhh,varargin)

[ok, mess, all_bins] = parse_char_options(varargin, {'-all'});
if ~ok
    error('HORACE:DnDBase:invalid_arguments', ...
        '%s.\nValid values for optional arguments are ''-al[l]''.', ...
        mess ...
        );
end

wout = win;
for i=1:numel(win)
    [q,en]=calculate_q_bins(win(i));

    weight=reshape(...
        disp2sqw(q, en, dispreln, pars, fwhh), ...
        size(win(i).s));
    if ~all_bins
        omit=(win(i).npix==0);
        if any(omit), weight(omit)=0; end
    end
    wout(i).s = weight;
    wout(i).e = zeros(size(data.e));
end