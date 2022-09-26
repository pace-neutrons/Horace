function [obj,nothing_to_do,npix_lo,npix_hi] = parse_get_pix_arguments_(obj,varargin)
%
if ischar(obj.num_contrib_files)
    error('HORACE:sqw_binfile_common:runtime_error',...
        'get_pix method called from un-initialized loader')
end

if ~obj.is_activated('read')
    obj = obj.activate('read');
end
nothing_to_do = false;

npix_tot = obj.npixels;
if isempty(npix_tot) % dnd object
    nothing_to_do = true;
    return
end

if nargin>1
    npix_lo = varargin{1};
    if nargin > 2
        npix_hi = varargin{2};
    else
        npix_hi = npix_tot;
    end
else
    npix_lo = 1;
    npix_hi = npix_tot;
end

if npix_lo < 1
    warning('HORACE:sqw_binfile_common:invalid_argument',...
        'get_pix: min pixel number requested smaller than 1, using 1')
    npix_lo = 1;
end
if npix_hi > npix_tot
    warning('HORACE:sqw_binfile_common:invalid_argument',...
        ['get_pix: max pixel number requested is bigger than total numeber of pixesls %d.',...
        ' using %d'],npix_tot,npix_tot);
    npix_hi = npix_tot;
end
