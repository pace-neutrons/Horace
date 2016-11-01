function obj = put_sample_instr_records_(obj,varargin)
% Calculate positions of sample and instrument records to place to binary
% sqw file
%
obj.check_obj_initated_properly();

header = obj.extract_correct_subobj('header');

n_files = numel(header);

% extract instrument and sample from headers block
instr = extract_subfield_(header,'instrument',n_files);
sampl = extract_subfield_(header,'sample',n_files);
%
% serialize instrument(s)
[bytes,instr_size] = serialize_block(obj,instr,'instrument');
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
[bytes,sample_size] = serialize_block(obj,sampl,'sample');
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

%
function [bytes,data_sz] = serialize_block(obj,data,type)
% serialize an instrument or sample data block
%
%type = class(data); % not yet a class or not always a class!
if isempty(data)
    bytes = [];
else
    form = obj.get_is_head_form(type);
    data_block = build_block_descriptor_(obj,data,type);
    bytes = obj.sqw_serializer_.serialize(data_block,form);
    sz = obj.([type,'_pos_'])-obj.([type,'_head_pos_']);
    if numel(bytes) ~= sz
        error('FACCESS_SQW_V3:runtime_error',...
            ' size of serialized %s header %d different from calculated value %d',...
            type,numel(bytes),sz);
    end
    
    data_form = obj.get_is_form();
    if data_block.all_same
        bytes2 = obj.sqw_serializer_.serialize(data(1),data_form);
    else
        bytes2 = obj.sqw_serializer_.calculate_positions(data,data_form);
    end
    data_sz = numel(bytes2);
    bytes = [bytes',bytes2];
end

