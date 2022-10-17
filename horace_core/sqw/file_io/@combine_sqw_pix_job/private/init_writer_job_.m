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
    error('COMBINE_PIX_JOB:runtime_error',...
        'Can not open target file %s for writing',filename);
end

pix_out_position = pix_comb_info.pix_out_pos;
do_fseek(fout,pix_out_position,'bof');
check_error_report_fail_(fout,...
    sprintf(['Unable to move to the start of the pixel'...
    ' record to write the target file %s '...
    'to start writing combined pixels'],...
    filename));

obj.fout_ = fout;

if obj.reader_id_shift_ == 1
    obj.pix_cache_ = pix_cache(...
        obj.mess_framework.numLabs-obj.reader_id_shift_,...
        obj.common_data_.nbin);
end

