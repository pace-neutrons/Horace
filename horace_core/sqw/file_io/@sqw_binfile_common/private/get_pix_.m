function pix  = get_pix_(obj,npix_lo,npix_hi)
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
% pix = obj.get_pix(___,'-raw_output') -- return raw pixel data and do not
%                                     wrap pixels into PixelData class
%
%
if ischar(obj.num_contrib_files)
    error('HORACE:sqw_binfile_common:runtime_error',...
        'get_pix method called from un-initialized loader')
end

if ~obj.is_activated('read')
    obj = obj.activate('read');
end

npix_tot = obj.npixels;
if isempty(npix_tot) % dnd object
    pix = zeros(9,0);
    return
end


% *** T.G.Perring 5 Sep 2018: Change code so that npix_lo=npix_hi+1 is allowed; this will result in no
% pixels being read
if npix_lo> npix_hi+1   % replaces the following line
    %if npix_lo> npix_hi
    error('HORACE:sqw_binfile_common:invalid_argument',...
        'requested number of min pixel %d is bigger then number of max pixel: %d',...
        npix_lo,npix_lo);
end

stride = (npix_lo-1)*9*4;
size = npix_hi-npix_lo+1;

try
    do_fseek(obj.file_id_,obj.pix_pos_+stride,'bof');
catch ME
    exc = MException('HORACE:sqw_binfile_common:io_error',...
                     'get_pix: Can not move to the beginning of the pixel block requested');
    throw(exc.addCause(ME))
end

if size>0
    pix = fread(obj.file_id_,[9,size],'float32');
    [mess,res] = ferror(obj.file_id_);
    if res ~= 0
        error('HORACE:sqw_binfile_common:io_error',...
            'get_pix: Error reading the pixel block requested: %s',mess);
    end
else
    % *** T.G.Perring 5 Sep 2018: allow for size=0
    pix = zeros(9,0);
end
