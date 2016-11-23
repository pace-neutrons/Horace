function  obj = put_sqw(obj,varargin)
% Save sqw file using sqw v3 binary format
%

obj = put_sqw@sqw_binfile_common(obj,varargin{:});

obj = put_sample_instr_records_(obj);
% should not be necessary, as init calculated it correctly, but to be on a
% safe side...
obj.position_info_pos_= obj.instr_sample_end_pos_;
obj = put_sqw_footer_(obj);



