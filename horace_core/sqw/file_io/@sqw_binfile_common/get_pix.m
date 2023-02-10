function pix  = get_pix(obj,varargin)
% read full or partial pixel information using properly initialized
% sqw file information
% Usage:
% assuming that file accessor is properly initiated
%>> pix  = obj.get_pix();            -- try to read and return all pixels
%                                       stored in the file (may fail due to insufficient
%                                       memory)
% pix  = obj.get_pix(npix_lo);
% pix  = obj.get_pix(npix_lo,npix_high); --
%                                    -- try to read pixels from pixel N npix_lo
%                                    to the end of pixels or from npix_lo
%                                    to the pixel N npix_hi


[obj,nothing_to_do,npix_lo,npix_hi] = parse_get_pix_arguments_(obj,varargin{:});
if nothing_to_do
    pix = PixelDataBase.create();
    return
end
pix  = get_pix_(obj,npix_lo,npix_hi);
if isempty(pix)
    pix = PixelDataBase.create();
else
    pix = PixelDataBase.create(pix);
    pix.full_filename = obj.full_filename;
end
