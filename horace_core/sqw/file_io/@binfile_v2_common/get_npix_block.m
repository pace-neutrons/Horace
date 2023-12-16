function npix = get_npix_block(obj,bin_start,bin_end)
% Read all or partial npix information describing distribution of pixels
% over the bins.
%
% Usage:
%>>npix = obj.get_npix_block(bin_start,bin_end);
% Inputs:
% bin_start  -- the number of the first elment of the npix array to read
% bin_end    -- the number of the last element of the npix array to read
%               The numbers correspond to the indexes of dnd.npix array if
%               this array is loaded in memory.
% Returns
% npix       -- array of numbers, describing number of pixels contributing
%               to each bin of image (dnd) array.

if ~isnumeric(obj.npix_pos_)
    error('HORACE:binfile_v2_common:invalid_argument', ...
        'Attemt to use uninifialized file-accessor to get npix data')
end

try
    do_fseek(obj.file_id_,obj.npix_pos_+(bin_start-1)*8,'bof');
catch ME
    exc = MException('HORACE:binfile_v2_common:io_error',...
        'Can not move to the signal start position');
    throw(exc.addCause(ME))
end

n_elem = bin_end-bin_start + 1;
npix = fread(obj.file_id_,n_elem,'uint64');

check_error_report_fail_(obj,...
    'get_npix_block: Can not read all or part of npix array');
