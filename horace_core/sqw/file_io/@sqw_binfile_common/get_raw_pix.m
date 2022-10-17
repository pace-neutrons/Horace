function pix  = get_raw_pix(obj,varargin)
% read full or partial pixel information using propertly initalized
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
    pix = zeros(9,0);
    return
end

pix  = get_pix_(obj,npix_lo,npix_hi);
