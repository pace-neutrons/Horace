function  obj = put_sqw(obj,varargin)
% Save sqw file using sqw v3 binary format
%

obj = put_sqw@sqw_binfile_common(obj,varargin{:});

obj = put_sample_instr_records_(obj);

obj = put_footer_(obj);



