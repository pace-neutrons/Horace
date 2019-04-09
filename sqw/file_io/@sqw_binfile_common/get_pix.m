function pix  = get_pix(obj,varargin)
% read full or partial pixel information using propertly initalized
% sqw file information
%
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)
%
if ischar(obj.num_contrib_files)
    error('SQW_FILE_INTERFACE:runtime_error',...
        'get_pix method called from un-initialized loader')
end

npix_tot = obj.npixels;
if isempty(npix_tot) % dnd object
    pix = zeros(9,0);
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
end

if npix_lo < 1
    warning('SQW_BINFILE_COMMON:invalid_argument',...
        'get_pix: min pixel number requested smaller than 1, using 1')
end
if npix_hi > npix_tot
    warning('SQW_BINFILE_COMMON:invalid_argument',...
        ['get_pix: max pixel number requested is bigger than total numeber of pixesls %d.',...
        ' using %d'],npix_tot,npix_tot);
end

% *** T.G.Perring 5 Sep 2018: Change code so that npix_lo=npix_hi+1 is allowed; this will result in no
% pixels being read
if npix_lo> npix_hi+1   % replaces the following line
%if npix_lo> npix_hi
    error('SQW_BINFILE_COMMON:invalid_argument',...
        'requested number of min pixel %d is bigger then number of max pixel: %d',...
        npix_lo,npix_lo);
end

stride = (npix_lo-1)*9*4;
size = npix_hi-npix_lo+1;
fseek(obj.file_id_,obj.pix_pos_+stride,'bof');
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('SQW_BINFILE_COMMON:io_error',...
        'get_pix: Can not move to the beginning of the pixel block requested, Reason: %s',mess);
end

if size>0
    pix = fread(obj.file_id_,[9,size],'float32');
    [mess,res] = ferror(obj.file_id_);
    if res ~= 0
        error('SQW_BINFILE_COMMON:io_error',...
            'get_pix: Error reading the pixel block requested: %s',mess);
    end
else
    % *** T.G.Perring 5 Sep 2018: allow for size=0
    pix = zeros(9,0);
end

