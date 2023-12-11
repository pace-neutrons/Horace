function npix = get_npix_block(obj,pos_start,pos_end)
% Read all or partial npix information describing distribution of pixels
% over the bins.
%
% Usage:
%>>data_struct = obj.get_npix_block(pos_start,pos_end);
% Inputs:
% pos_start  -- the number of the first elment of the npix array to read
% pos_end    -- the number of the last element of the npix array to read
%

if ~isnumeric(obj.npix_pos_)
    error('HORACE:binfile_v2_common:invalid_argument', ...
        'Attemt to use uninifialized file-accessor to get npix data')
end

try
    do_fseek(obj.file_id_,obj.npix_pos_+(pos_start-1)*8,'bof');
catch ME
    exc = MException('HORACE:binfile_v2_common:io_error',...
        'Can not move to the signal start position');
    throw(exc.addCause(ME))
end

n_elem = pos_end-pos_start + 1;
npix = fread(obj.file_id_,n_elem,'uint64');
%npix = double(npix);

check_error_report_fail_(obj,...
    'get_npix_block: Can not read all or part of npix array');
