function [obj,nothing_to_do,npix_lo,npix_hi,raw_output] = parse_get_pix_arguments_(obj,varargin)
%


if ischar(obj.num_contrib_files)
    error('HORACE:faccess_sqw_v4:runtime_error',...
        'get_pix method called from un-initialized loader')
end

[ok,mess,raw_output,argi] = parse_char_options(varargin,'-raw_output');
if ~ok
    error('HORACE:faccess_sqw_v4:invalid_argument',mess)
end


if ~obj.is_activated('read')
    obj = obj.activate('read');
end
nothing_to_do = false;

npix_tot = obj.npixels;
if isempty(npix_tot) % dnd object
    nothing_to_do = true;
    npix_lo=0;
    npix_hi=0;    
    return
end

nargi = numel(argi);
if nargi >0
    npix_lo = argi{1};
    if nargi > 1
        npix_hi = argi{2};
    else
        npix_hi = npix_tot;
    end
else
    npix_lo = 1;
    npix_hi = npix_tot;
end

if npix_lo < 1
    warning('HORACE:faccess_sqw_v4:invalid_argument',...
        'get_pix: min pixel number requested smaller than 1, using 1')
    npix_lo = 1;
end
if npix_hi > npix_tot
    warning('HORACE:faccess_sqw_v4:invalid_argument',...
        ['Max number of pixels requested is bigger than the total number of pixels: %d\n',...
        ' Max number of pixels to read is reset to max number of pixels available'],npix_tot);
    npix_hi = npix_tot;
end
