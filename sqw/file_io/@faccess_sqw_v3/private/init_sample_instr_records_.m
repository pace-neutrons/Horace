function obj = init_sample_instr_records_(obj)
% Calculate positions of sample and instrument records to place to binary
% sqw file
%

header = obj.extract_correct_subobj('header');

n_files = numel(header);

% extract instrument and sample from headers block
instr = extract_subfield_(header,'instrument',n_files);
sampl = extract_subfield_(header,'sample',n_files);
%
% calculate positions, these objects occupy on hdd
pos = obj.eof_pix_pos_;
[pos,obj] = data_block_size(obj,instr,'instrument',pos);
[pos,obj] = data_block_size(obj,sampl,'sample',pos);
obj.instr_sample_end_pos_ = pos;
%
function [pos,obj] = data_block_size(obj,data,type,pos)
% calculate positions of & within an instrument or sample data block

%type = class(data);
obj.([type,'_head_pos_']) = pos;
if isempty(data)
    obj.([type,'_pos_']) = pos;
else
    form = obj.get_is_head_form(type);
    data_block = build_block_descriptor_(obj,data,type);
    [~,pos] = obj.sqw_serializer_.calculate_positions(form,data_block,pos);
    obj.([type,'_pos_']) = pos;
    data_form = obj.get_is_form();
    if data_block.all_same
        [~,pos] = obj.sqw_serializer_.calculate_positions(data_form,data(1),pos);
    else
        [~,pos] = obj.sqw_serializer_.calculate_positions(data_form,data,pos);
    end
end

