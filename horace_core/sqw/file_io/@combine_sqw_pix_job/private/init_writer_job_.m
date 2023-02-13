function [obj] = init_writer_job_(obj)
% process job inputs and return initial information for writer job
%
%Returns:
% obj  -- JobExecutor instance, with initialized messages cache
% fout -- initialized handle for opened binary file to write data

pix_comb_info = obj.pix_combine_info_;

filename = pix_comb_info.fout_name;
fout = fopen(filename,'rb+');
if fout<=0
    error('HORACE:combine_sqw_pix_job:runtime_error',...
        'Can not open target file %s for writing',filename);
end

pix_out_position = pix_comb_info.pix_out_pos;
try
    do_fseek(fout,pix_out_position,'bof');
catch ME
    exc = MException('HORACE:combine_sqw_pix_job:io_error', ...
                     ['Unable to move to the start of the pixel'...
                      ' record to write the target file '...
                      'to start writing combined pixels']);
    ME=ME.addCause(exc);
    rethrow(ME)
end

obj.fout_ = fout;

if obj.reader_id_shift_ == 1
    obj.pix_cache_ = pix_cache(...
        obj.mess_framework.numLabs-obj.reader_id_shift_,...
        obj.common_data_.nbin);
end
