function [obj,instrument_start,instrument_size,sample_start,sample_size] = ...
    init_sample_instr_records_(obj)
% Calculate positions of sample and instrument records to place to binary
% sqw file
%

exp_info = obj.extract_correct_subobj('header');

[instr_str,sampl_str] = obj.get_instr_sample_to_save(exp_info);

% calculate positions, these objects occupy on hdd
pos = obj.eof_pix_pos_;
instrument_start = pos;
[pos,obj] = data_block_size(obj,instr_str,'instrument',pos);
instrument_size  = pos - instrument_start;
sample_start     = pos;
[pos,obj] = data_block_size(obj,sampl_str,'sample',pos);
obj.instr_sample_end_pos_ = pos;
sample_size = pos - sample_start;
%
function [pos,obj] = data_block_size(obj,data,type,pos)
% calculate positions of & within an instrument or sample data block
% return the position where the next data block would start

%type = class(data);
obj.([type,'_head_pos_']) = pos;
if isempty(data)
    obj.([type,'_pos_']) = pos;
else
    form = obj.get_si_head_form(type);
    data_block = build_block_descriptor_(obj,data,type);
    [~,pos] = obj.sqw_serializer_.calculate_positions(form,data_block,pos);
    obj.([type,'_pos_']) = pos;
    data_form = obj.get_si_form();
    if data_block.all_same
        if iscell(data)
            [~,pos] = obj.sqw_serializer_.calculate_positions(data_form,data{1},pos);
        else
            [~,pos] = obj.sqw_serializer_.calculate_positions(data_form,data(1),pos);
        end
    else
        [~,pos] = obj.sqw_serializer_.calculate_positions(data_form,data,pos);
    end
end

