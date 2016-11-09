function obj = put_sample_instr_records_(obj,varargin)
% Calculate positions of sample and instrument records to place to binary
% sqw file
%
obj.check_obj_initated_properly();

header = obj.extract_correct_subobj('header');


% extract instrument and sample from headers block
instr = extract_subfield_(header,'instrument');
sampl = extract_subfield_(header,'sample');
%
% serialize instrument(s)
[bytes,instr_size] = serialize_si_block_(obj,instr,'instrument');
clc_size = obj.sample_head_pos_ - obj.instrument_pos_;
if instr_size ~= clc_size
    error('FACCESS_SQW_V3:runtime_error',...
        ' size of serialized instrument %d different from the calculated value %d',...
        instr_size,sz);
end
%
start = obj.instrument_head_pos_;
fseek(obj.file_id_,start,'bof');
check_error_report_fail_(obj,'can not move to the instrument(s) start position');
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'error writing serialized instrument(s)');

% serialize sample(s)
[bytes,sample_size] = serialize_si_block_(obj,sampl,'sample');
clc_size = obj.instr_sample_end_pos_ - obj.sample_pos_;
if sample_size ~= clc_size
    error('FACCESS_SQW_V3:runtime_error',...
        ' size of serialized sample %d different from the calculated value %d',...
        sample_size,sz);
end
fseek(obj.file_id_,obj.sample_head_pos_,'bof');
check_error_report_fail_(obj,'can not move to the sample(s) start position');
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'error writing  serialized sample(s)');

%
obj.real_eof_pos_ = ftell(obj.file_id_);

