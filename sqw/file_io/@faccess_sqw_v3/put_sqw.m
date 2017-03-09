function  obj = put_sqw(obj,varargin)
% Save sqw file using sqw v3 binary format
%

obj = put_sqw@sqw_binfile_common(obj,varargin{:});

pix_end = obj.eof_pix_pos_;
fseek(obj.file_id_,0,'eof');
file_end = ftell(obj.file_id_);
if uint64(pix_end) - uint64(file_end)>0
    warning('FACCESS_SQW_V3:runtime_error',...
        'file end position %d is not equal to pixel end position: %d',...
        pix_end,file_end);
end

obj = put_sample_instr_records_(obj);
% should not be necessary, as init calculated it correctly, but to be on a
% safe side...
obj.position_info_pos_= obj.instr_sample_end_pos_;
obj = put_sqw_footer_(obj);



